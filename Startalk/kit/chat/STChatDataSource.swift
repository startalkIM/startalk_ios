//
//  STChatDataSource.swift
//  Startalk
//
//  Created by lei on 2023/3/27.
//

import Foundation

class STChatDataSource{
    static let DEFAULT_COUNT = 10
    
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
    }
    
    func chat(at index: Int) -> STChat{
        if index >= chats.count{
            let offset = chats.count
            let count = index + 1 - chats.count
            let moreChats = storage.chats(offset: offset, count: count)
            chats.append(contentsOf: moreChats)
        }
        return chats[index]
    }
}
