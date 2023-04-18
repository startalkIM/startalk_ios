//
//  STChat.swift
//  Startalk
//
//  Created by lei on 2023/3/9.
//

import Foundation
import XMPPClient
import CoreData

struct STChat{
    static let VOICE_TYPE = "voice"
    static let IMAGE_TYPE = "image"
    static let VIDEO_TYPE = "video"
    static let FILE_TYPE = "file"
    
    var id: String
    var isGroup: Bool
    var title: String?
    var photo: String?
    var lastMessage: STMessage?
    var draft: String?
    var unreadCount: Int
    var isSticky: Bool
    var isMuted: Bool
    var timestamp: Date
    
    var defaultTitle: String{
        if isGroup{
            return "Group".localized
        }else{
            return id
        }
    }
    
    var brief: String{
        guard let message = lastMessage else{
            return ""
        }
        let brief: String
        switch message.type{
        case .text:
            brief = message.content.value
        case .voice:
            brief = "[\(Self.VOICE_TYPE)]"
        case .image:
            brief = "[\(Self.IMAGE_TYPE)]"
        case .file:
            brief = "[\(Self.FILE_TYPE)]"
        @unknown default:
            brief = message.content.value
        }
        return brief
    }
    
    var state: STMessage.State{
        return lastMessage?.state ?? .unspecified
    }
}

extension STChat{
    
    @discardableResult
    func MakeChatMO(context: NSManagedObjectContext) -> ChatMO{
        let chatMo = ChatMO(context: context)
        chatMo.xmppId = id
        chatMo.isGroup = isGroup
        chatMo.title = title
        chatMo.photo = photo
        chatMo.draft = draft
        chatMo.unreadCount = Int32(unreadCount)
        chatMo.isSticky = isSticky
        chatMo.isMuted = isMuted
        chatMo.timestamp = timestamp
        
        if let lastMessage = lastMessage{
            chatMo.lastMessage = lastMessage.makeMessageMo(context: context)
        }
        return chatMo
    }
}

extension ChatMO{
    var chat: STChat{
        var message: STMessage? = nil
        if let lastMessageMo = lastMessage{
            message = lastMessageMo.message
        }
        
        return STChat(id: xmppId!, isGroup: isGroup, title: title, photo: photo, lastMessage: message, draft: draft, unreadCount: Int(unreadCount), isSticky: isSticky, isMuted: isMuted, timestamp: timestamp!)
    }
}
