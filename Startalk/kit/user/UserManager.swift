//
//  UserManager.swift
//  Startalk
//
//  Created by lei on 2023/4/17.
//

import Foundation
import XMPPClient

class UserManager{
    let logger = STLogger(UserManager.self)
    
    lazy var userState = STKit.shared.userState
    lazy var serviceManager = STKit.shared.serviceManager
    lazy var apiClient = STKit.shared.apiClient
    lazy var connection = STKit.shared.databaseManager.getUserConnection()
    
    func fetchUser(jid: XCJid) -> User?{
        fetchUser(username: jid.name, domain: jid.domain)
    }
    
    func fetchUser(username: String, domain: String) -> User?{
        let sql = "select * from user where username = ? and domain = ?"
        var user: User?
        do{
            let resultSet = try connection.query(sql: sql, values: username, domain)
            if resultSet.next(){
                let id = try resultSet.getInt32("id")
                let username = try resultSet.getString("username")!
                let domain = try resultSet.getString("domain")!
                let name = try resultSet.getString("name")
                let genderValue = try resultSet.getInt32("gender")
                let photo = try resultSet.getString("photo")
                let bio = try resultSet.getString("bio")
                
                let gender = Gender(rawValue: Int(genderValue))
                user = User(id: Int(id), username: username, domain: domain, name: name, gender: gender, photo: photo, bio: bio)
            }
        }catch{
            logger.warn("fetch user failed", error)
        }
        return user
    }
    
    func tryAddUser(username: String, domain: String){
        let sql = "insert or ignore into user(username, domain) values(?, ?)"
        do{
            try connection.insert(sql: sql, values: username, domain)
        }catch{
            logger.warn("add user failed", error)
        }
    }
    
    func tryAddProfiles(userId: Int){
        let userId = Int32(userId)
        let sql = "insert or ignore into user_profiles(user_id) values(?)"
        do{
            try connection.insert(sql: sql, values: userId)
        }catch{
            logger.warn("add user_profiles failed")
        }
    }
    
    func fetchProfiles() -> UserProfiles?{
        var profiles: UserProfiles?
        
        let userId = Int32(userState.userId)
        let sql = "select * from user_profiles where user_id = ?"
        do{
            let resultSet =  try connection.query(sql: sql, values: userId)
            if resultSet.next(){
                let id = try resultSet.getInt32("id")
                let userId = try resultSet.getInt32("user_id")
                let usersVersion = try resultSet.getInt32("users_version")
                let groupsUpdateTime = try resultSet.getInt64("groups_update_time")
                profiles = UserProfiles(id: Int(id), userId: Int(userId), usersVersion: Int(usersVersion), groupsUpdateTime: groupsUpdateTime)
            }
        }catch{
            logger.warn("fetch user profiles failed", error)
        }
        return profiles
    }
    
    func updateUsers(updated: [User], deleted: [User], version: Int){
        let updateSql = """
            insert into user(username, domain, name, gender) values(?, ?, ?, ?)
            on conflict(username, domain) do update set name = ?, gender = ?
            """
        let updateValues = updated.map { user in
            let gender = user.gender?.rawValue.int32
            return [user.username, user.domain, user.name, gender, user.name, gender]as [SQLiteBindable?]
        }
        do{
            try connection.batchUpdate(sql: updateSql, values: updateValues)
        }catch{
            logger.warn("update users failed", error)
        }
        
        
        let deleteSql = "delete from user where username = ? and domain = ?"
        let deleteValues = deleted.map { user in
            [user.username, user.domain]
        }
        do{
            try connection.batchUpdate(sql: deleteSql, values: deleteValues)
        }catch{
            logger.warn("delete users failed", error)
        }
        
        let updateVersionSql = "update user_profiles set users_version = ? where user_id = ?"
        do{
            try connection.update(sql: updateVersionSql, values: version.int32, userState.userId.int32)
        }catch{
            logger.warn("update users version failed", error)
        }
    }
    
    func storeUserDetail(user: User){
        let sql = "update user set name = ?, photo = ?, bio = ? where usernmae = ? and domain = ?"
        do{
            try connection.update(sql: sql, values: user.name, user.photo, user.bio, user.username, user.domain)
        }catch{
            logger.warn("store user detail failed", error)
        }
    }
    
    func updateGroupUpdateTime(time: Int64){
        let sql = "update user_profiles set groups_update_time = ? where user_id = ?"
        do{
            try connection.update(sql: sql, values: time, userState.userId.int32)
        }catch{
            logger.warn("update group update time failed", error)
        }
    }
}

extension UserManager{
    static let UPDATE_USERS_PATH = "/update/getUpdateUsers.qunar"
    static let DETAIL_PATH = "/domain/get_vcard_info.qunar"
    static let DETAIL_DEFAULT_VERSION = 0
    
    func updateUsers(){
        let domain = serviceManager.domain
        let profiles = fetchProfiles()
        
        let version = profiles?.usersVersion ?? 0
        let entity = ["version": version]
        let url = apiClient.buildUrl(path: Self.UPDATE_USERS_PATH)
        Task{
            let result: ApiFetchResult<UpdatedUsers> = await apiClient.fetch(url, entity: entity)
            if case .success(let updatedUsers) = result {
                let updated =  updatedUsers.update.map{$0.user(domain: domain)}
                let deleted = updatedUsers.delete.map{$0.user(domain: domain)}
                let version = updatedUsers.version
                updateUsers(updated: updated, deleted: deleted, version: version)
            }
        }
    }
    
    func fetchUserDetails(_ usernames: [String], domain: String) async -> [User]{
        let url = apiClient.buildUrl(path: Self.DETAIL_PATH)
        
        let userInfos = usernames.map { username in
            UserDetailRequest.UserInfo(user: username, version: Self.DETAIL_DEFAULT_VERSION)
        }
        let entity = [UserDetailRequest(domain: domain, users: userInfos)]
        let result: ApiFetchResult<[UserDetailResponse]> = await apiClient.fetch(url, entity: entity)
        
        var details: [User] = []
        switch result{
        case .success(let array):
            if let responseDetails = array.first?.users{
                details = responseDetails.map{ responseDetail in
                    responseDetail.user
                }
            }
        case .failure(let reason):
            logger.info("fetch user detail failed: \(reason)")
        }
        return details
    }
    
    struct UpdatedUser: Codable{
        var U: String
        var N: String
        var sex: Int
        
        func user(domain: String) -> User{
            let gender = Gender(rawValue: sex)
            return User(username: U, domain: domain, name: N, gender: gender)
        }
    }
    
    struct UpdatedUsers: Codable{
        var update: [UpdatedUser]
        var delete: [UpdatedUser]
        var version: Int
    }
    
    struct UserDetailRequest: Codable{
        struct UserInfo: Codable{
            var user: String
            var version: Int
        }
        var domain: String
        var users: [UserInfo]
    }
    
    struct UserDetailResponse: Codable{
        struct UseDetail: Codable{
            var username: String
            var domain: String
            var nickname: String
            var gender: String
            var imageurl: String
            var email: String
            var mood: String
            
            var user: User{
                User(username: username, domain: domain, name: nickname, photo: imageurl, bio: mood)
            }
        }
        var domain: String
        var users: [UseDetail]
    }
}
