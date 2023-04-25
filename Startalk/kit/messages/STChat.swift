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
    init?(_ resultSet: SQLiteResultSet) throws {
        let id = try resultSet.getString("xmpp_id")
        guard let id = id else {
            return nil
        }
        self.id = id
        let groupValue = try resultSet.getInt32("is_group")
        self.isGroup = (groupValue == 1)
        self.title = try resultSet.getString("title")
        self.photo = try resultSet.getString("photo")
        self.draft = try resultSet.getString("draft")
        
        let unreadCount = try resultSet.getInt32("unread")
        self.unreadCount = Int(unreadCount)
        let stickyValue = try resultSet.getInt32("is_sticky")
        self.isSticky = (stickyValue == 1)
        let mutedValue = try resultSet.getInt32("is_muted")
        self.isMuted = (mutedValue == 1)
        let milliseconds = try resultSet.getInt64("timestamp")
        self.timestamp = Date(milliseconds: milliseconds)
        
    }
}
