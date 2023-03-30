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
    
    enum State{
        case sending
        case sent
        case failed
        case read
        
        static let unspecified = Self.sent
    }
}

extension STMessage: Codable{
    
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
        case content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let headerContainer = try container.nestedContainer(keyedBy: HeaderKeys.self, forKey: .message)
        let from = try headerContainer.decode(String.self, forKey: .from)
        let to = try headerContainer.decode(String.self, forKey: .to)
        let realFrom = try? headerContainer.decode(String.self, forKey: .realfrom)
        let timeText = try headerContainer.decode(String.self, forKey: .msec_times)
        let time = Int64(timeText)!

        let contentContainer = try container.nestedContainer(keyedBy: ContentKeys.self, forKey: .body)
        let id = try contentContainer.decode(String.self, forKey: .id)
        let content = try contentContainer.decode(String.self, forKey: .content)

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
        
        let messageContent = XCTextMessageContent(value: content)
        let messsage = XCMessage(header: header, id: id, type: .text, content: messageContent, clientType: .ios, timestamp: time)

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