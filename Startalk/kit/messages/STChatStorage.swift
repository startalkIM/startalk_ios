//
//  STChatStorage.swift
//  Startalk
//
//  Created by lei on 2023/3/27.
//

import Foundation

class STChatStorage{
    
    lazy var databaseManager = STKit.shared.databaseManager
    
    func addMessages(_ messages: [STMessage]){
        let context = databaseManager.context
        
        let messages = reduce(messages)
        let chatIds = messages.map { $0.xmppId }
        
        let request = ChatMO.fetchRequest()
        request.predicate = NSPredicate(format: "xmppId in %@", chatIds)
        let chatMOs = databaseManager.fetch(request)
        let chatMap = chatMOs.dict { $0.xmppId! }
        
        for message in messages {
            let chatId = message.xmppId
            let isUnread = message.direction == .receive && message.state == .sent
            let unreadValue: Int32 = isUnread ? 1 : 0
            let messageMO = message.makeMessageMo(context: context)
            
            let chatMO = chatMap[chatId]
            if let chatMO = chatMO{
                chatMO.lastMessage = messageMO
                chatMO.unreadCount += unreadValue
                chatMO.timestamp = message.timestamp
            }else{
                let chatMO = ChatMO(context: context)
                chatMO.xmppId = chatId
                chatMO.isGroup = message.isGroup
                chatMO.lastMessage = messageMO
                chatMO.unreadCount = unreadValue
                chatMO.isSticky = false
                chatMO.isMuted = false
                chatMO.timestamp = message.timestamp
            }
        }
        
        databaseManager.save()
    }
    
    func count() -> Int{
        let request = ChatMO.fetchRequest()
        return databaseManager.count(for: request)
    }
    
    func chats(offset: Int = 0, count: Int = 10) -> [STChat] {
        let request = ChatMO.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchOffset = offset
        request.fetchLimit = count
        let chatMOs = databaseManager.fetch(request)
        return chatMOs.map { $0.chat }
    }
    
    func chat(withId id: String) -> STChat?{
        let request = ChatMO.fetchRequest()
        request.predicate = NSPredicate(format: "xmppId = %@", id)
        let chatMOs = databaseManager.fetch(request)
        return chatMOs.first?.chat
    }
    
    private func reduce(_ messages: [STMessage]) -> [STMessage]{
        var messageMap: [String: STMessage] = [: ]
        for message in messages {
            let chatId = message.xmppId
            let value = messageMap[chatId]
            if value == nil || message.timestamp > value!.timestamp{
                messageMap[chatId] = message
            }
        }
        return Array(messageMap.values)
    }
}
