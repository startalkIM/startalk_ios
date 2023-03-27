//
//  STMessages.swift
//  Startalk
//
//  Created by lei on 2023/3/20.
//

import Foundation

class STMessageStorage{
    
    var messages: [STMessage] = []
    
    var lastMessageTimestamp: Date?{
        messages.last?.timestamp
    }
    
    func addMessages(_ newMessages: [STMessage]){
        for newMessage in newMessages {
            var index = messages.count
            for i in stride(from: self.messages.count - 1, through: 0, by: -1){
                let message = messages[i]
                if message.timestamp <= newMessage.timestamp{
                    break
                }
                index -= 1
            }
            messages.insert(newMessage, at: index)
        }
    }
    
    func updateMessage(withId id: String, state: STMessage.State){
        for i in 0..<messages.count{
            if messages[i].id == id{
                messages[i].state = state
            }
        }
    }
    
    func messagesCount(chatId: String) -> Int{
        messages.filter { message in
            message.xmppId == chatId
        }.count
    }
    
    func messages(chatId: String, offset: Int = 0, count: Int = 10) -> [STMessage]{
        let chatMessages = messages.filter { message in
            message.xmppId == chatId
        }
        let upper = offset + count
        let slice = chatMessages[offset..<upper]
        return Array(slice)
    }
}
