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
        //return messages.first?.timestamp
        return nil
    }
    
    func addMessages(_ messages: [STMessage]){
        let context = databaseManager.context
        for message in messages {
            let mo = message.makeMessageMo(context: context)
            print(mo.from!, mo.to!)
        }
        databaseManager.save()
    }
    
    func updateMessage(withId id: String, state: STMessage.State){
        let request = MessageMO.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id)
        let messages = databaseManager.fetch(request)
        if let message = messages.first{
            message.state = Int16(state.rawValue)
        }
        databaseManager.save()
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
                if message.from == userState.jid.bare{
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
}
