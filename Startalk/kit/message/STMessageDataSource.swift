//
//  STMessageDataSource.swift
//  Startalk
//
//  Created by lei on 2023/3/27.
//

import Foundation

class STMessageDataSource{
    static let DAFAULT_COUNT = 10
        
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
        let batchCount = min(count, Self.DAFAULT_COUNT)
        let offset = count - batchCount
        messages = storage.messages(chatId: chatId, offset: offset, count: batchCount)
    }
    
    func message(at index: Int) -> STMessage{
        let unloadedCount = count - messages.count
        if index < unloadedCount{
            let loadCount = unloadedCount - index
            let moreMessages = storage.messages(chatId: chatId, offset: index, count: loadCount)
            messages.insert(contentsOf: moreMessages, at: 0)
        }
        let index = index - (count - messages.count)
        return messages[index]
    }
}
