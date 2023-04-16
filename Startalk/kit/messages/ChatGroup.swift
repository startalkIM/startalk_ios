//
//  ChatGroup.swift
//  Startalk
//
//  Created by lei on 2023/4/16.
//

import Foundation

struct ChatGroup{
    var xmppId: String
    var name: String
    var photo: String?
    
    init(xmppId: String, name: String, photo: String? = nil) {
        self.xmppId = xmppId
        self.name = name
        self.photo = photo
    }
}

extension ChatGroup{
    
    init(_ groupMo: ChatGroupMO){
        xmppId = groupMo.xmppId!
        name = groupMo.name!
        photo = groupMo.photo
    }
    
    func fillGroupMO(_ groupMo: ChatGroupMO){
        groupMo.xmppId = xmppId
        groupMo.name = name
        groupMo.photo = photo
    }
}
