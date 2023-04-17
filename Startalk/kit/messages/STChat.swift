//
//  STChat.swift
//  Startalk
//
//  Created by lei on 2023/3/9.
//

import Foundation
import XMPPClient

struct STChat{
    static let VOICE_TYPE = "voice"
    static let IMAGE_TYPE = "image"
    static let VIDEO_TYPE = "video"
    static let FILE_TYPE = "file"
    
    var id: String
    var isGroup: Bool
    var title: String?
    var photo: String
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
