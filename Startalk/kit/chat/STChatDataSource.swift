//
//  STChatDataSource.swift
//  Startalk
//
//  Created by lei on 2023/3/27.
//

import Foundation

class STChatDataSource{
    static let DEFAULT_COUNT = 10
    lazy var serviceManager = STKit.shared.serviceManager
    
    let storage: STChatStorage
    
    var count = 0
    var chats: [STChat] = []
    
    init(storage: STChatStorage) {
        self.storage = storage
       
        reload()
    }
    
    func reload(){
        count = storage.count()
        chats = storage.chats(offset: 0, count: Self.DEFAULT_COUNT)
        
        chats = complement(chats)
    }
    
    func chat(at index: Int) -> STChat{
        if index >= chats.count{
            let offset = chats.count
            let count = index + 1 - chats.count
            var moreChats = storage.chats(offset: offset, count: count)
            moreChats = complement(moreChats)
            chats.append(contentsOf: moreChats)
        }
        return chats[index]
    }
    
    private func complement(_ chats: [STChat]) -> [STChat]{
        var chats = chats
        for i in chats.indices{
            var chat = chats[i]
            if let photo = chat.photo{
                chat.photo = serviceManager.attachFilePrefixIfAbsent(photo)
                chats[i] = chat
            }
        }
        return chats
    }
}
