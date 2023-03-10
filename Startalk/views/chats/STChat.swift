//
//  STChat.swift
//  Startalk
//
//  Created by lei on 2023/3/9.
//

import Foundation

struct STChat{
    enum Status{
        case sending
        case sent
        case failed
        case received
    }
    
    var id: Int
    var isGroup: Bool
    var title: String
    var photo: String
    var brief: String
    var status: Status
    var unreadCount: Int
    var isSticky: Bool
    var isMuted: Bool
    var timestamp: Date
}
