//
//  ChatGroup.swift
//  Startalk
//
//  Created by lei on 2023/4/16.
//

import Foundation
import CoreData

struct Group{
    var xmppId: String
    var name: String
    var photo: String?
    
    init(xmppId: String, name: String, photo: String? = nil) {
        self.xmppId = xmppId
        self.name = name
        self.photo = photo
    }
}

extension Group{
    
    @discardableResult
    func makeGroupMO(context: NSManagedObjectContext) -> GroupMO{
        let groupMo = GroupMO(context: context)
        groupMo.xmppId = xmppId
        groupMo.name = name
        groupMo.photo = photo
        return groupMo
    }
}

extension GroupMO{
    var group: Group{
        Group(xmppId: xmppId!, name: name!, photo: photo)
    }
}
