//
//  STChatDataSource.swift
//  Startalk
//
//  Created by lei on 2023/3/27.
//

import Foundation

class STChatDataSource{
    let storage: STChatStorage
    
    var count = 0
    var chats: [STChat] = []
    
    init(storage: STChatStorage) {
        self.storage = storage
       
        reload()
    }
    
    func chat(at index: Int) -> STChat{
        chats[index]
    }
    
    func reload(){
        count = storage.count()
        chats = storage.chats(offset: 0, count: count)
    }
}
