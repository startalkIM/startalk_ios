//
//  STMessage.swift
//  Startalk
//
//  Created by lei on 2023/3/20.
//

import Foundation
import XMPPClient

struct STMessage{
    private var message: XCMessage
    var direction: Direction = .unspecified
    var state: State = .unspecified
    
    init(message: XCMessage, direction: Direction, state: State) {
        self.message = message
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

        let fromJid = XCJid(from)
        guard let fromJid = fromJid else{
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
        let header = XCHeader(from: fromJid, to: toJid, realFrom: realFromJid, realTo: nil, isGroup: false)
        
        let messsage = XCMessage(header: header, id: id, type: messageType, content: messageContent, clientType: .ios, timestamp: time)

        var read = true
        if container.contains(.read_flag){
            let readInt = try container.decode(Int.self, forKey: .read_flag)
            read = (readInt == 1)
        }

        self.message = messsage
        
        if read{
            self.state = .read
        }
    }
    
    func encode(to encoder: Encoder) throws{
        
    }
}


extension STMessage{
    
    var id: String{
        message.id
    }
    var from: String{
        get{
            message.header.from.bare
        }
        set{
            if let jid = XCJid(newValue){
                message.header.from = jid
            }
        }
    }
    var to: String{
        get{
            message.header.to.bare
        }
        set{
            if let jid = XCJid(newValue){
                message.header.to = jid
            }
        }
    }
    var realFrom: String?{
        message.header.realFrom?.bare
    }
    var isGroup: Bool{
        get{
            message.header.isGroup
        }
        set{
            message.header.isGroup = newValue
        }
    }
    var xmppId: String{
        let xmppId: XCJid
        let header = message.header
        if header.isGroup{
            xmppId = header.to
        }else{
            switch direction{
            case .receive:
                xmppId = header.from
            case .send:
                xmppId = header.to
            }
        }
        return xmppId.bare
    }
    var type: XCMessageType{
        message.type
    }
    var content: XCMessageContent{
        message.content
    }
    var timestamp: Date{
        Date(milliseconds: message.timestamp)
    }
}

extension STMessage{
    init?(_ messageMo: MessageMO){
        let from = messageMo.from?.jid
        let to = messageMo.to?.jid
        let isGroup = messageMo.isGroup
        
        guard let from = from, let to = to else{
            return nil
        }
        let header = XCHeader(from: from, to: to, isGroup: isGroup)

        let id = messageMo.id
        let typeValue = Int(messageMo.type)
        let type = XCMessageType(rawValue: typeValue)
        let content = messageMo.content?.messageContent(type)
        let clientTypeValue = Int(messageMo.clientType)
        let clientType = XCClientType(rawValue: clientTypeValue)
        let timestamp = messageMo.timestamp?.milliseconds
        
        guard let id = id, let type = type, let content = content, let clientType = clientType, let timestamp = timestamp else{
            return nil
        }
        let message = XCMessage(header: header, id: id, type: type, content: content, clientType: clientType, timestamp: timestamp)
        
        let stateValue = Int(messageMo.state)
        let state = STMessage.State(rawValue: stateValue)
        guard let state = state else{
            return nil
        }
        
        self.message = message
        self.state = state
    }
    
    func fillMessageMo(_ messageMo: MessageMO){
        messageMo.from = from
        messageMo.to = to
        messageMo.isGroup = isGroup
        
        messageMo.id = message.id
        messageMo.type = Int16(message.type.rawValue)
        messageMo.content = message.content.value
        messageMo.clientType = Int16(message.clientType.rawValue)
        messageMo.timestamp = Date(milliseconds: message.timestamp)
    
        messageMo.state = Int16(state.rawValue)
    }
}
