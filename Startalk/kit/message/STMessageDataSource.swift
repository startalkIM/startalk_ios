//
//  STMessageDataSource.swift
//  Startalk
//
//  Created by lei on 2023/3/27.
//

import Foundation

class STMessageDataSource{
    static let DAFAULT_COUNT = 10
    lazy var fileStorage = STKit.shared.filesManager.storage
        
    let storage: STMessageStorage
    let chatId: String
    
    var count: Int = 0
    var messages: [STMessage] = []
    
    init(storage: STMessageStorage, chatId: String) {
        self.storage = storage
        self.chatId = chatId
        
        reload()
    }
    
    var unloadedCount: Int{
        count - messages.count
    }
    
    func reload(){
        count = storage.messagesCount(chatId: chatId)
        let batchCount = min(count, Self.DAFAULT_COUNT)
        let offset = count - batchCount
        messages = storage.messages(chatId: chatId, offset: offset, count: batchCount)
        for i in messages.indices{
            complement(message: &messages[i])
        }
    }
    
    func message(at index: Int) -> STMessage{
        if index < unloadedCount{
            let loadCount = unloadedCount - index
            var moreMessages = storage.messages(chatId: chatId, offset: index, count: loadCount)
            for i in moreMessages.indices{
                complement(message: &moreMessages[i])
            }
            messages.insert(contentsOf: moreMessages, at: 0)
        }
        let index = index - unloadedCount
        return messages[index]
    }
    
    func index(of messageId: String) -> Int?{
        var index = messages.firstIndex { message in
            message.id == messageId
        }
        if let i = index{
            index = i + unloadedCount
        }
        return index
    }
    
    func reload(at index: Int){
        if unloadedCount <= index && index < count{
            let index = index - unloadedCount
            let messageId = messages[index].id
            let message = storage.fetchMessage(id: messageId)
            if var message = message{
                complement(message: &message)
                messages[index] = message
            }
        }
    }
    
    private func complement(message: inout STMessage){
        let fileName = message.localFile
        if let fileName = fileName{
            let filePath = fileStorage.getPersistentPath(name: fileName)
            message.localFile = filePath
        }
    }
}
