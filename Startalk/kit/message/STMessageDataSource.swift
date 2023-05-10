//
//  STMessageDataSource.swift
//  Startalk
//
//  Created by lei on 2023/3/27.
//

import Foundation

class STMessageDataSource{
    let storage: STMessageStorage
    let chatId: String
    
    var count: Int = 0
    var messages: [STMessage] = []
    
    init(storage: STMessageStorage, chatId: String) {
        self.storage = storage
        self.chatId = chatId
        
        reload()
    }
    
    func reload(){
        count = storage.messagesCount(chatId: chatId)
        messages = storage.messages(chatId: chatId, offset: 0, count: count)
    }
    
    func message(at index: Int) -> STMessage{
        return messages[index]
    }
}
