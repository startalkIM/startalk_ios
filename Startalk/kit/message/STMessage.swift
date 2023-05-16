//
//  STMessage.swift
//  Startalk
//
//  Created by lei on 2023/3/20.
//

import Foundation
import XMPPClient
import CoreData

struct STMessage{
    var id: String
    var from: XCJid
    var to: XCJid
    var isGroup: Bool
    var type: XCMessageType
    var content: XCMessageContent
    var clientType: XCClientType
    var state: State = .unspecified
    var timestamp: Date
    var direction: Direction = .unspecified
    
    init(id: String, from: XCJid, to: XCJid, isGroup: Bool, type: XCMessageType, content: XCMessageContent, clientType: XCClientType, state: State, timestamp: Date, direction: Direction) {
        self.id = id
        self.from = from
        self.to = to
        self.isGroup = isGroup
        self.type = type
        self.content = content
        self.clientType = clientType
        self.state = state
        self.timestamp = timestamp
        self.direction = direction
    }
    
    init(message: XCMessage, direction: Direction = .unspecified, state: State) {
        self.id = message.id
        self.from = message.header.from
        self.to = message.header.to
        self.isGroup = message.header.isGroup
        self.type = message.type
        self.content = message.content
        self.clientType = message.clientType
        self.timestamp = Date(milliseconds: message.timestamp)
        self.direction = direction
        self.state = state
    }
    
    static func receive(_ message: XCMessage) -> STMessage{
        STMessage(message: message, direction: .receive, state: .sent)
    }
    
    static func send(_ message: XCMessage) -> STMessage{
        STMessage(message: message, direction: .send, state: .sending)
    }
}

extension STMessage{
    
    enum Direction{
        case send
        case receive
        
        static let unspecified = Self.send
    }
    
    enum State: Int{
        case sending
        case sent
        case failed
        case read
        case revoked
        
        static let unspecified = Self.sent
    }
}

extension STMessage: Codable{
    static let GROUP_CHAT_TYPE = "groupchat"
    static let decoder = JSONDecoder()
    
    enum CodingKeys: CodingKey{
        case message
        case body
        case read_flag
    }
    
    enum HeaderKeys: CodingKey{
        case from
        case to
        case realfrom
        case type
        case client_type
        case msec_times
    }
    
    enum ContentKeys: CodingKey{
        case id
        case msgType
        case content
        case extendInfo
    }
    
    private struct RevokeExtendInfo: Codable{
        var messageId: String
        var fromId: String
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let headerContainer = try container.nestedContainer(keyedBy: HeaderKeys.self, forKey: .message)
        let to = try headerContainer.decode(String.self, forKey: .to)
        let realFrom = try headerContainer.decodeIfPresent(String.self, forKey: .realfrom)
        let chatType = try headerContainer.decode(String.self, forKey: .type)
        let timeText = try headerContainer.decode(String.self, forKey: .msec_times)
        let time = Int64(timeText)!

        let contentContainer = try container.nestedContainer(keyedBy: ContentKeys.self, forKey: .body)
        let id = try contentContainer.decode(String.self, forKey: .id)
        let typeText = try contentContainer.decode(String.self, forKey: .msgType)
        let content = try contentContainer.decode(String.self, forKey: .content)
        
        let type = Int(typeText)
        guard let type = type else{
            throw DecodingError.dataCorruptedError(forKey: .msgType, in: contentContainer, debugDescription: "message type not integer")
        }
        let from: String
        var messageType: XCMessageType = .text
        var messageContent: XCMessageContent = XCTextMessageContent(value: content)
        if type == XCMessageType.revoke{
            let extendInfoText = try contentContainer.decode(String.self, forKey: .extendInfo)
            let data = extendInfoText.data(using: .utf8)
            guard let data = data else {
                throw DecodingError.dataCorruptedError(forKey: .extendInfo, in: contentContainer, debugDescription: "extend info is not utf8 encoding")
            }
            let extendInfo = try Self.decoder.decode(RevokeExtendInfo.self, from: data)
            from = extendInfo.fromId
        }else{
            from = try headerContainer.decode(String.self, forKey: .from)
            let type = XCMessageType(rawValue: type)
            if let type = type{
                messageType = type
                let content = XCMessage.makeContent(content, type: type)
                guard let content = content else {
                    throw DecodingError.dataCorruptedError(forKey: .content, in: contentContainer, debugDescription: "invalid content")
                }
                messageContent = content
            }
        }

        let readFlag = try container.decodeIfPresent(Int.self, forKey: .read_flag)
        
        let fromJid = XCJid(from)
        guard var fromJid = fromJid else{
            throw DecodingError.dataCorruptedError(forKey: .from, in: headerContainer, debugDescription: "could not parse from")
        }
        let toJid = XCJid(to)
        guard let toJid = toJid else{
            throw DecodingError.dataCorruptedError(forKey: .to, in: headerContainer, debugDescription: "could not parse to")
        }
        var realFromJid: XCJid? = nil
        if let realFrom = realFrom{
            realFromJid = XCJid(realFrom)
        }
        
        fromJid = realFromJid ?? fromJid
        
        self.id = id
        self.from = fromJid
        self.to = toJid
        self.isGroup = (chatType == Self.GROUP_CHAT_TYPE)
        self.type = messageType
        self.content = messageContent
        self.clientType = .ios
        self.timestamp = Date(milliseconds: time)
        self.state = (readFlag == 1) ? .read : .sent
    }
    
    func encode(to encoder: Encoder) throws{
        
    }
}

extension STMessage{
    mutating func resetDirection(with selfJid: XCJid){
        if from.bare == selfJid.bare{
            direction = .send
        }else{
            direction = .receive
        }
    }
    
    var chatId: String{
        if isGroup{
            return to.bare
        }else{
            if direction == .send{
                return to.bare
            }else{
                return from.bare
            }
        }
    }
}

extension STMessage{
    
    init?(_ resultSet: SQLiteResultSet) throws {
        let id = try resultSet.getString("message_id")
        let from = try resultSet.getString("sender")
        let fromJid = from?.jid
        let to = try resultSet.getString("receiver")
        let toJid = to?.jid
        let groupValue = try resultSet.getInt32("is_group")
        let typeValue = try resultSet.getInt32("type")
        let type = XCMessageType(rawValue: Int(typeValue))
        let contentValue = try resultSet.getString("content") ?? ""
        var content: XCMessageContent = XCTextMessageContent(value: contentValue)
        if let type = type{
            content = XCMessage.makeContent(contentValue, type: type) ?? content
        }
        let clientTypeValue = try resultSet.getInt32("client_type")
        let clientType = XCClientType(rawValue: Int(clientTypeValue))
        let stateValue = try resultSet.getInt32("state")
        let state = State(rawValue: Int(stateValue))
        let milliseconds = try resultSet.getInt64("timestamp")
        guard let id = id, let fromJid = fromJid, let toJid = toJid, let type = type, let clientType = clientType, let state = state else{
            return nil
        }
        self.id = id
        self.from = fromJid
        self.to = toJid
        self.isGroup = (groupValue == 1)
        self.type = type
        self.content = content
        self.clientType = clientType
        self.state = state
        self.timestamp = Date(milliseconds: milliseconds)
    }
}
