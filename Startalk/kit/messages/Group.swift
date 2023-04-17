//
//  ChatGroup.swift
//  Startalk
//
//  Created by lei on 2023/4/16.
//

import Foundation

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
    
    init(_ groupMo: GroupMO){
        xmppId = groupMo.xmppId!
        name = groupMo.name!
        photo = groupMo.photo
    }
    
    func fillGroupMO(_ groupMo: GroupMO){
        groupMo.xmppId = xmppId
        groupMo.name = name
        groupMo.photo = photo
    }
}
