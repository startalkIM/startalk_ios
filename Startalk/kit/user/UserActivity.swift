//
//  UserActivity.swift
//  Startalk
//
//  Created by lei on 2023/4/17.
//

import Foundation
import CoreData

struct UserActivity{
    var id: Int
    var lastMessageTime: Int64?
    
    init(id: Int, lastMessageTime: Int64? = nil) {
        self.id = id
        self.lastMessageTime = lastMessageTime
    }
}

extension UserActivity{
    
    @discardableResult
    func makeActivityMO(context: NSManagedObjectContext) -> UserActivityMO {
        let activityMo = UserActivityMO(context: context)
        activityMo.id = Int16(id)
        if let lastMessageTime = lastMessageTime{
            activityMo.lastMessageTime = Date(milliseconds: lastMessageTime)
        }
        return activityMo
    }
}

extension UserActivityMO{
    var activity: UserActivity{
        let id = Int(id)
        let lastMessageTime = lastMessageTime?.milliseconds
        return UserActivity(id: id, lastMessageTime: lastMessageTime)
    }
}
