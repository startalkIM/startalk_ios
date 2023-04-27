//
//  STMessages.swift
//  Startalk
//
//  Created by lei on 2023/3/20.
//

import Foundation

class STMessageStorage{
    lazy var databaseManager = STKit.shared.databaseManager2
    lazy var userState = STKit.shared.userState
    let logger = STLogger(STMessageStorage.self)
        
    func lastMessageTime(user: String) -> Date?{
        let sql = "select max(timestamp) from message"
        var date: Date?
        do{
            let resultSet = try databaseManager.query(sql: sql)
            if resultSet.next(){
                let timestamp = try resultSet.getInt64(0)
                if timestamp != 0 {
                    date = Date(milliseconds: timestamp)
                }
            }
        }catch{
            logger.warn("get last message time failed", error)
        }
        return date
    }
    func addMessages(_ messages: [STMessage]) -> Int{
        let sql = """
        insert into message
        (message_id, chat_id, sender, receiver, is_group, type, content, client_type, state, timestamp)
        values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var values: [[SQLiteBindable?]] = []
        for message in messages {
            let messageValues: [SQLiteBindable?] = [
                message.id,
                message.chatId,
                message.from.value,
                message.to.value,
                message.isGroup ? 1 : 0,
                Int32(message.type.rawValue),
                message.content.value,
                Int32(message.clientType.rawValue),
                Int32(message.state.rawValue),
                message.timestamp.milliseconds
            ]
            values.append(messageValues)
        }
        do{
            return try databaseManager.batchInsert(sql: sql, values: values)
        }catch{
            logger.error("insert messages failed", error)
            return 0
        }
    }
    
    func updateMessage(withId id: String, state: STMessage.State){
        let sql = "update message set state = ? where message_id = ?"
        do{
            let stateValue = Int32(state.rawValue)
            try databaseManager.update(sql: sql, values: stateValue, id)
        }catch{
            logger.warn("update message failed", error)
        }
    }
    
    func messagesCount(chatId: String) -> Int{
        let sql = "select count(1) from message where chat_id = ?"
        var count = 0
        do{
            let resultSet = try databaseManager.query(sql: sql, values: chatId)
            resultSet.next()
            let value = try resultSet.getInt64(0)
            count = Int(value)
        }catch{
            logger.warn("get message count failed", error)
        }
        return count
    }
    
    func messages(chatId: String, offset: Int = 0, count: Int = 10) -> [STMessage]{
        let sql = "select * from message where chat_id = ? order by timestamp asc limit ? offset ?"
        var messages: [STMessage] = []
        do{
            let offset = Int32(offset)
            let limit = Int32(count)
            let resultSet = try databaseManager.query(sql: sql, values: chatId, limit, offset)
            while resultSet.next(){
                let message = try STMessage(resultSet)
                if var message = message{
                    message.resetDirection(with: userState.jid)
                    messages.append(message)
                }
            }
        }catch{
            logger.warn("fetch messages failed", error)
        }
        return messages
    }
    
    func setMessagesRead(chatId: String, isGroup: Bool){
        let sql = "update message set state = ? where chat_id = ? and state = ?"
        do{
            let readValue = Int32(STMessage.State.read.rawValue)
            let sentValue = Int32(STMessage.State.sent.rawValue)
            try databaseManager.update(sql: sql, values: readValue, chatId, sentValue)
        }catch{
            logger.warn("set messages read failed", error)
        }
    }
}
