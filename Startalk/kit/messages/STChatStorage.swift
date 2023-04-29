//
//  STChatStorage.swift
//  Startalk
//
//  Created by lei on 2023/3/27.
//

import Foundation

class STChatStorage{
    let logger = STLogger(STChatStorage.self)
    
    lazy var databaseManager = STKit.shared.databaseManager2
    
    func addMessages(_ messages: [STMessage]){
        let connection = databaseManager.getConnection()
        let entries = reduce(messages)
        do{
            for entry in entries {
                let (message, unreadCount) = entry
                let unreadValue = Int32(unreadCount)
                
                let querySql = "select * from chat where xmpp_id = ?"
                let resultSet = try connection.query(sql: querySql, values: message.chatId)
                if resultSet.next(){
                    let updateSql = """
                        update chat set unread = unread + ?,
                        last_message_id = (select id from message where message_id = ?),
                        timestamp = ?
                        where xmpp_id = ?
                        """
                    try connection.update(sql: updateSql, values: unreadValue, message.id, message.timestamp.milliseconds, message.chatId)
                }else{
                    let insertSql = """
                        insert into chat(xmpp_id, is_group, last_message_id, unread, timestamp)
                        values(?, ?, (select id from message where message_id = ?), ?, ?)
                        """
                    try connection.insert(sql: insertSql, values: message.chatId, message.isGroup, message.id, unreadValue, message.timestamp.milliseconds)
                }
            }
        }catch{
            logger.warn("add messages to chat failed", error)
        }
    }
    
    func count() -> Int{
        let sql = "select count(1) from chat"
        let connection = databaseManager.getConnection()
        var count = 0
        do{
            let resultSet = try connection.query(sql: sql)
            resultSet.next()
            let value = try resultSet.getInt32(0)
            count = Int(value)
        }catch{
            logger.warn("query chat count failed", error)
        }
        return count
    }
    
    func chats(offset: Int = 0, count: Int = 10) -> [STChat] {
        let sql = "select * from chat order by timestamp desc limit ? offset ?"
        let connection = databaseManager.getConnection()
        var chats: [STChat] = []
        do{
            let limit = Int32(count)
            let offset = Int32(offset)
            let resultSet = try connection.query(sql: sql, values: limit, offset)
            while resultSet.next(){
                let chat = try STChat(resultSet)
                let messageId = try resultSet.getInt32("last_message_id")
                if var chat = chat{
                    let messageSql = "select * from message where id = ?"
                    //TODO: refactor this
                    let messageResultSet = try connection.query(sql: messageSql, values: messageId)
                    if messageResultSet.next(){
                        chat.lastMessage = try STMessage(messageResultSet)
                    }
                    chats.append(chat)
                }
            }
        }catch{
            logger.warn("query chats failed", error)
        }
        return chats
    }
    
    func chat(withId id: String) -> STChat?{
        let sql = "select * from chat where xmpp_id = ?"
        let connection = databaseManager.getConnection()
        var chat: STChat?
        do{
            let resultSet = try connection.query(sql: sql, values: id)
            if resultSet.next(){
                chat = try STChat(resultSet)
            }
        }catch{
            logger.warn("query chat failed", error)
        }
        return chat
    }
    
    private func reduce(_ messages: [STMessage]) -> [(STMessage, Int)]{
        var messageMap: [String: (STMessage, Int)] = [: ]
        for message in messages {
            let chatId = message.chatId
            let value = messageMap[chatId]
            if value == nil{
                messageMap[chatId] = (message, 0)
            }
            
            if message.timestamp > messageMap[chatId]!.0.timestamp{
                messageMap[chatId]!.0 = message
            }
            
            if message.direction == .receive && message.state == .sent{
                messageMap[chatId]!.1 += 1
            }
            
            
        }
        return Array(messageMap.values)
    }
    
    func clearUnreadCount(_ chatId: String){
        let sql = "update chat set unread = 0 where xmpp_id = ?"
        let connection = databaseManager.getConnection()
        do{
            try connection.update(sql: sql, values: chatId)
        }catch{
            logger.warn("clear unread count failed", error)
        }
    }
}
