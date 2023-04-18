//
//  UserManager.swift
//  Startalk
//
//  Created by lei on 2023/4/17.
//

import Foundation

class UserManager{
    let logger = STLogger(UserManager.self)
    
    lazy var databaseManager = STKit.shared.databaseManager
        
    func fetchUser(username: String, domain: String) -> User?{
        let userMo = fetchUserMO(username: username, domain: domain)
        return userMo?.user
    }
    
    func addUser(_ user: User){
        let context = databaseManager.context
        user.makeUserMO(context: context)
        databaseManager.save()
    }
    
    private func fetchUserMO(username: String, domain: String) -> UserMO?{
        let request = UserMO.fetchRequest()
        request.predicate = NSPredicate(format: "username = %@ and domain = %@", username, domain)
        let userMOs: [UserMO] = databaseManager.fetch(request)
        
        return userMOs.first
    }
    
    private func fetchOrAddUserMO(username: String, domain: String) -> UserMO{
        let context = databaseManager.context
        let userMO: UserMO
        if let one = fetchUserMO(username: username, domain: domain){
            userMO = one
        }else{
            userMO = UserMO(context: context)
            userMO.username = username
            userMO.domain = domain
        }
        return userMO
    }
    
    func fetchOrAddActivity(username: String, domain: String) -> UserActivity{
        let context = databaseManager.context
        let userMO = fetchOrAddUserMO(username: username, domain: domain)
        
        let activityMO: UserActivityMO
        if let one = userMO.activity{
            activityMO = one
        }else{
            let id = fetchMaxActivityId() ?? 1
            activityMO = UserActivityMO(context: context)
            activityMO.id = id
            userMO.activity = activityMO
        }
        
        databaseManager.save()
        return activityMO.activity
    }
    
    private func fetchMaxActivityId() -> Int16?{
        var id: Int16?
        let request = UserActivityMO.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        request.fetchLimit = 1
        let activityMOs = databaseManager.fetch(request)
        if let lastActivityMO = activityMOs.first{
            id = lastActivityMO.id + 1
        }
        return id
    }
}
