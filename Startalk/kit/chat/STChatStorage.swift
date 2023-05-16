//
//  STChatStorage.swift
//  Startalk
//
//  Created by lei on 2023/3/27.
//

import Foundation
import XMPPClient

class STChatStorage{
    let logger = STLogger(STChatStorage.self)
    
    lazy var connection = STKit.shared.databaseManager.getUserConnection()
    
    func fetchChats(ids: [String]) -> [STChat]{
        let idsPhrase = ids.map { "'\($0)'"}.joined(separator: ", ")
        let sql = "select * from chat where xmpp_id in (\(idsPhrase))"
        var chats: [STChat] = []
        do{
            let resultSet = try connection.query(sql: sql)
            while resultSet.next(){
                let chat = try STChat(resultSet)!
                chats.append(chat)
            }
        }catch{
            logger.warn("query chats failed", error)
        }
        return chats
    }
    
    func addChats(_ chats: [STChat]){
        let sql = """
            insert into chat(xmpp_id, is_group, title, photo, last_message_id, unread, timestamp)
            values(?, ?, ?, ?, (select id from message where message_id = ?), ?, ?)
            """
        let values = chats.map { chat in
            [chat.id, chat.isGroup, chat.title, chat.photo, chat.lastMessage?.id, Int32(chat.unreadCount), chat.timestamp.milliseconds] as [SQLiteBindable?]
        }
        do {
            try connection.batchUpdate(sql: sql, values: values)
        } catch{
            logger.warn("insert chat failed", error)
        }
    }
    
    func updateChats(_ chats: [STChat]){
        let sql = """
            update chat set unread = ?, last_message_id = (select id from message where message_id = ?),
            timestamp = ? where xmpp_id = ?
            """
        let values = chats.map { chat in
            [Int32(chat.unreadCount), chat.lastMessage?.id, chat.timestamp.milliseconds, chat.id] as [SQLiteBindable?]
        }
        do {
            try connection.batchUpdate(sql: sql, values: values)
        } catch {
            logger.warn("update chat failed")
        }
    }
    
    func updateChats(details: [(String, String?, String?)]){
        let sql = "update chat set title = ?, photo = ? where xmpp_id = ?"
        let values = details.map { (id, title, photo) in
            [title, photo, id]
        }
        do {
            try connection.batchUpdate(sql: sql, values: values)
        } catch {
            logger.warn("update chat photos failed")
        }
    }
        
    func count() -> Int{
        let sql = "select count(1) from chat"
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
        let sql = """
            select c.*, m.message_id m_id, m.type m_type, m.content m_content
            from chat c left join message m on c.last_message_id = m.id
            order by timestamp desc limit ? offset ?
            """
        var chats: [STChat] = []
        do{
            let limit = Int32(count)
            let offset = Int32(offset)
            let resultSet = try connection.query(sql: sql, values: limit, offset)
            while resultSet.next(){
                let chat = try STChat(resultSet)
                if let chat = chat{
                    chats.append(chat)
                }
            }
        }catch{
            logger.warn("query chats failed", error)
        }
        return chats
    }
    
    func chat(withId id: String) -> STChat?{
        let sql = """
            select c.*, m.message_id m_id, m.type m_type, m.content m_content
            from chat c left join message m on c.last_message_id = m.id
            where xmpp_id = ?
            """
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
    
   
    
    func clearUnreadCount(_ chatId: String){
        let sql = "update chat set unread = 0 where xmpp_id = ?"
        do{
            try connection.update(sql: sql, values: chatId)
        }catch{
            logger.warn("clear unread count failed", error)
        }
    }
}
