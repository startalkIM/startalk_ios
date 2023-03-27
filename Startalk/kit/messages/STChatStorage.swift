//
//  STChatStorage.swift
//  Startalk
//
//  Created by lei on 2023/3/27.
//

import Foundation

class STChatStorage{
    var chats: [STChat] = []
    
    func addMessages(_ messages: [STMessage]){
        for message in messages{
            let index = chats.firstIndex { chat in
                chat.id == message.xmppId
            }
            let unread = message.direction == .receive && message.state != .read
            if let index = index{
                chats[index].brief = STChat.makeBrief(message)
                chats[index].state = message.state
                chats[index].unreadCount += unread ? 1 : 0
                chats[index].timestamp = message.timestamp
            }else{
                let chat = STChat(
                    id: message.xmppId,
                    isGroup: message.isGroup,
                    title: STChat.makeTitle(message),
                    photo: "",
                    brief: STChat.makeBrief(message),
                    state: message.state,
                    unreadCount: unread ? 1 : 0,
                    isSticky: false,
                    isMuted: false,
                    timestamp: message.timestamp)
                chats.append(chat)
            }
        }
        
        chats.sort { chat1, chat2 in
            chat1.timestamp > chat2.timestamp
        }
        
    }
    
    func updateMessage(withId id: String, state: STMessage.State){
        
    }
    
    func count() -> Int{
        chats.count
    }
    
    func chats(offset: Int = 0, count: Int = 10) -> [STChat] {
        let upper = offset + count
        let slice = chats[offset..<upper]
        return Array(slice)
    }
    
    func chat(withId id: String) -> STChat?{
        chats.first { chat in
            chat.id == id
        }
    }
}
