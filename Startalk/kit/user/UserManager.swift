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
    
    func fetchProfiles(userId: Int) -> UserProfiles?{
        var profiles: UserProfiles?
        
        let userId = Int32(userId)
        let sql = "select * from user_profiles where user_id = ?"
        do{
            let resultSet =  try connection.query(sql: sql, values: userId)
            if resultSet.next(){
                let id = try resultSet.getInt32("id")
                let userId = try resultSet.getInt32("user_id")
                let usersVersion = try resultSet.getInt32("users_version")
                profiles = UserProfiles(id: Int(id), userId: Int(userId), usersVersion: Int(usersVersion))
            }
        }catch{
            logger.warn("fetch user profiles failed", error)
        }
        return profiles
    }
    
    func updateUsers(users: [User]){
        let sql = """
            insert into user(username, domain, name, gender) values(?, ?, ?, ?)
            on conflict(username, domain) do update set name = ?, gender = ?
            """
        let values = users.map { user in
            let gender = user.gender?.rawValue.int32
            return [user.username, user.domain, user.name, gender, user.name, gender]as [SQLiteBindable?]
        }
        do{
            try connection.batchInsert(sql: sql, values: values)
        }catch{
            logger.warn("update users failed", error)
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
}

extension UserManager{
    static let UPDATE_USERS_PATH = "/update/getUpdateUsers.qunar"
    static let DETAIL_PATH = "/domain/get_vcard_info.qunar"
    
    func updateUsers(){
        let username = userState.username
        let domain = serviceManager.domain
        let user = fetchUser(username: username, domain: domain)
        guard let user = user else { return }
        let profiles = fetchProfiles(userId: user.id)
        
        let version = profiles?.usersVersion ?? 0
        let entity = ["version": version]
        let url = apiClient.buildUrl(path: Self.UPDATE_USERS_PATH)
        Task{
            let result: STApiResult<UpdatedUsers> = await apiClient.post(url, entity: entity)
            if case .response(let updatedUsers) = result {
                let users =  updatedUsers.update.map{$0.user(domain: domain)}
                updateUsers(users: users)
                
            }
        }
    }
    
    func fetchUserDetail(_ username: String, domain: String, completion: @escaping (User?) -> Void){
        let url = apiClient.buildUrl(path: Self.DETAIL_PATH)
        let entity = [UserDetailRequest(domain: domain, users: [UserDetailRequest.UserInfo(user: username, version: 0)])]
        Task{
            var user: User?
            let result: STApiResult<[UserDetailResponse]> = await apiClient.post(url, entity: entity)
            switch result{
            case .response(let array):
                user = array.first?.users.first?.makeUser(username: username, domain: domain)
            case .success:
                break //won't reach here
            case .failure(let reason):
                logger.info("fetch user detail failed: \(reason)")
            }
            completion(user)
        }
       
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
            var nickname: String
            var gender: String
            var imageurl: String
            var mood: String
            var v: String
            
            func makeUser(username: String, domain: String) -> User{
                return User(username: username, domain: domain, name: nickname, photo: imageurl, bio: mood)
            }
        }
        var domain: String
        var users: [UseDetail]
    }
}
