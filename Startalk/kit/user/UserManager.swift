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
    lazy var chatManager = STKit.shared.chatManager
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
                user = try User(resultSet: resultSet)
            }
        }catch{
            logger.warn("fetch user failed", error)
        }
        return user
    }
    
    func fetchUsers(xmppIds: [String]) -> [User]{
        let xmppIdsPhrase = xmppIds.map { "'\($0)'" }.joined(separator: ", ")
        let sql = "select * from user where xmpp_id in(\(xmppIdsPhrase))"
        var users: [User] = []
        do {
            let resultSet = try connection.query(sql: sql)
            while resultSet.next(){
                let user = try User(resultSet: resultSet)
                if let user = user{
                    users.append(user)
                }
            }
        } catch {
            logger.warn("fetch users failed", error)
        }
        return users
    }
    
    func tryAddUser(username: String, domain: String){
        let sql = "insert or ignore into user(username, domain, xmpp_id) values(?, ?, ?)"
        let xmppId = XCJid(name: username, domain: domain).bare
        do{
            try connection.insert(sql: sql, values: username, domain, xmppId)
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
            insert into user(username, domain, xmpp_id, name, gender) values(?, ?, ?, ?, ?)
            on conflict(username, domain) do update set name = ?, gender = ?
            """
        let updateValues = updated.map { user in
            let gender = user.gender?.rawValue.int32
            return [user.username, user.domain, user.xmppId.bare, user.name, gender, user.name, gender]as [SQLiteBindable?]
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
    
    func storeUserDetails(details: [User]){
        let sql = "update user set name = ?, photo = ?, bio = ? where username = ? and domain = ?"
        let values = details.map { user in
            [user.name, user.photo, user.bio, user.username, user.domain]
        }
        do{
            try connection.batchUpdate(sql: sql, values: values)
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
                
                chatManager.usersUpdated(users: updated)
                
                let usernames = updated.map { $0.username }
                await updateUserDetails(usernames, domain: domain)
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
    
    func updateUserDetails(_ usernames: [String], domain: String) async{
        let userDetails = await fetchUserDetails(usernames, domain: domain)
        storeUserDetails(details: userDetails)
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
