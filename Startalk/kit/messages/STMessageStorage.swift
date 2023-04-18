//
//  STMessages.swift
//  Startalk
//
//  Created by lei on 2023/3/20.
//

import Foundation

class STMessageStorage{
    
    lazy var databaseManager = STKit.shared.databaseManager
    lazy var userState = STKit.shared.userState
        
    func lastMessageTime(user: String) -> Date?{
        let request = MessageMO.fetchRequest()
        request.predicate = makeFetchConditon(user)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        let messages = databaseManager.fetch(request)
        return messages.first?.timestamp
    }
    
    func addMessages(_ messages: [STMessage]){
        let context = databaseManager.context
        for message in messages {
            message.makeMessageMo(context: context)
        }
        databaseManager.save()
    }
    
    func updateMessage(withId id: String, state: STMessage.State) -> Bool{
        var isLast = false
        let request = MessageMO.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id)
        let messages = databaseManager.fetch(request)
        if let message = messages.first{
            message.state = Int16(state.rawValue)
            isLast = (message.chat != nil)
        }
        databaseManager.save()
        return isLast
    }
    
    func messagesCount(chatId: String) -> Int{
        let request = MessageMO.fetchRequest()
        request.predicate = makeFetchConditon(chatId)
        return databaseManager.count(for: request)
    }
    
    func messages(chatId: String, offset: Int = 0, count: Int = 10) -> [STMessage]{
        let request = MessageMO.fetchRequest()
        request.predicate = makeFetchConditon(chatId)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        request.fetchOffset = offset
        request.fetchLimit = count
        let messageMOs = databaseManager.fetch(request)
        
        var messages: [STMessage] = []
        for messageMO in messageMOs {
            let message = messageMO.message
            if var message = message{
                if userState.isSelf(message.from){
                    message.direction = .send
                }else{
                    message.direction = .receive
                }
                messages.append(message)
            }
        }
        return messages
    }
    
    private func makeFetchConditon(_ xmppId: String) -> NSPredicate{
        NSPredicate(format: "from = %@ or to = %@", xmppId, xmppId)
    }
    
    func setMessagesRead(chatId: String, isGroup: Bool){
        let request = MessageMO.fetchRequest()
        let chatPredicate: NSPredicate
        if isGroup{
            let selfId = userState.jid.bare
            chatPredicate = NSPredicate(format: "to = %@ and from != %@", chatId, selfId)
        }else{
            chatPredicate = NSPredicate(format: "from = %@", chatId)
        }
        let state = STMessage.State.sent
        let statePredicate = NSPredicate(format: "state = %i", Int16(state.rawValue))
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [chatPredicate, statePredicate])
        
        let messageMOs = databaseManager.fetch(request)
        for messageMO in messageMOs {
            messageMO.state = Int16(STMessage.State.read.rawValue)
        }
        
        databaseManager.save()
    }
}
