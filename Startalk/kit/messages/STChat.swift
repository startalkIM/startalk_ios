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
    var title: String
    var photo: String
    var messageId: String?
    var brief: String
    var state: STMessage.State
    var unreadCount: Int
    var isSticky: Bool
    var isMuted: Bool
    var timestamp: Date
    
    static func makeBrief(_ message: STMessage) -> String{
        let brief: String
        switch message.type{
        case .text:
            brief = message.content.value
        case .voice:
            brief = "[\(VOICE_TYPE)]"
        case .image:
            brief = "[\(IMAGE_TYPE)]"
        case .file:
            brief = "[\(FILE_TYPE)]"
        @unknown default:
            brief = message.content.value
        }
        return brief
    }
    
    static func makeTitle(_ message: STMessage) -> String{
        if message.isGroup{
            return "Group"
        }else{
            switch message.direction{
            case .send:
                return message.to
            case .receive:
                return message.from
            }
        }
    }
}
