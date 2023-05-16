//
//  ChatManager.swift
//  Startalk
//
//  Created by lei on 2023/5/14.
//

import Foundation
import XMPPClient

class ChatManager{
    lazy var userManager = STKit.shared.userManager
    lazy var groupManager = STKit.shared.groupManager
    
    var storage = STChatStorage()

    
    func addMessages(_ messages: [STMessage]){
        let chats = makeChats(messages)
        let chatDict = chats.dict{ $0.id }
        let ids = chats.map { $0.id }
        
        var existingChats = storage.fetchChats(ids: ids)
        for i in existingChats.indices {
            var existingChat = existingChats[i]
            let chat = chatDict[existingChat.id]!
            existingChat.lastMessage = chat.lastMessage
            existingChat.unreadCount += chat.unreadCount
            existingChat.timestamp = chat.timestamp
            existingChats[i] = existingChat
        }
        let existingIds = existingChats.map { $0.id }
        storage.updateChats(existingChats)
        
        
        let newChats = chats.filter { chat in
            !existingIds.contains(chat.id)
        }
        var privateChats = newChats.filter{ !$0.isGroup }
        let privateIds = privateChats.map{ $0.id }
        let users = userManager.fetchUsers(xmppIds: privateIds)
        let userDict = users.dict { $0.xmppId.bare}
        for i in privateChats.indices{
            var chat = privateChats[i]
            let user = userDict[chat.id]
            if let user = user{
                chat.title = user.name
                chat.photo = user.photo
                privateChats[i] = chat
            }
        }
        
        var groupChats = newChats.filter{ $0.isGroup }
        let groupIds = groupChats.map{ $0.id }
        let groups = groupManager.fetchGroups(xmppIds: groupIds)
        let groupDict = groups.dict{ $0.xmppId }
        for i in groupChats.indices{
            var chat = groupChats[i]
            let group = groupDict[chat.id]
            if let group = group{
                chat.title = group.name
                chat.photo = group.photo
                groupChats[i] = chat
            }
        }
        storage.addChats(privateChats + groupChats)
        
        var domainUsernames: [String: [String]] = [: ]
        for user in users {
            if user.photo == nil{
                var usernames = domainUsernames[user.domain] ?? []
                usernames.append(user.username)
                domainUsernames[user.domain] = usernames
            }
        }
        for (domain, usernames) in domainUsernames{
            Task{
                let users = await userManager.fetchUserDetails(usernames, domain: domain)
                let details = users.compactMap { user in
                    (user.xmppId.bare, user.name, user.photo)
                }
                storage.updateChats(details: details)
            }
        }
    }
    
    private func makeChats(_ messages: [STMessage]) -> [STChat]{
        var dict: [String: STChat] = [: ]
        for message in messages {
            let chatId = message.chatId
            var chat: STChat
            
            if let value = dict[chatId]{
                chat = value
                if message.timestamp > chat.timestamp{
                    chat.timestamp = message.timestamp
                    chat.lastMessage = message
                }
            }else{
                chat = STChat(id: chatId, isGroup: message.isGroup, lastMessage: message, unreadCount: 0, isSticky: false, isMuted: false, timestamp: message.timestamp)
            }
            
            if message.direction == .receive && message.state == .sent{
                chat.unreadCount += 1
            }
            dict[chatId] = chat
            
        }
        return Array(dict.values)
    }
    
    func clearUnreadCount(_ id: String){
        storage.clearUnreadCount(id)
    }
}

extension ChatManager{
    func usersUpdated(users: [User]){
        let details = users.map { user in
            (user.xmppId.bare, user.name, user.photo)
        }
        storage.updateChats(details: details)
    }
    
    func groupsUpdated(groups: [Group]){
        let details = groups.map { group in
            (group.xmppId, group.name, group.photo)
        }
        storage.updateChats(details: details)
    }
}

extension ChatManager{
    
    func makeChatDataSource() -> STChatDataSource{
        return STChatDataSource(storage: storage)
    }
    
}
