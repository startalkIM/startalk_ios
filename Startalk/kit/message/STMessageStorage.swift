//
//  STMessages.swift
//  Startalk
//
//  Created by lei on 2023/3/20.
//

import Foundation

class STMessageStorage{
    lazy var connection = STKit.shared.databaseManager.getUserConnection()
    lazy var userState = STKit.shared.userState
    let logger = STLogger(STMessageStorage.self)
        
    func lastMessageTime(user: String) -> Date?{
        let sql = "select max(timestamp) from message"
        var date: Date?
        do{
            let resultSet = try connection.query(sql: sql)
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
        (message_id, chat_id, sender, receiver, is_group, type, content, client_type, local_file, state, timestamp)
        values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
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
                message.localFile,
                Int32(message.state.rawValue),
                message.timestamp.milliseconds
            ]
            values.append(messageValues)
        }
        do{
            return try connection.batchUpdate(sql: sql, values: values)
        }catch{
            logger.error("insert messages failed", error)
            return 0
        }
    }
    
    func updateMessage(withId id: String, state: STMessage.State){
        let sql = "update message set state = ? where message_id = ?"
        do{
            let stateValue = Int32(state.rawValue)
            try connection.update(sql: sql, values: stateValue, id)
        }catch{
            logger.warn("update message failed", error)
        }
    }
    
    func tryUpdateMessageAsFailed(id: String) -> Bool{
        let sql = "update message set state = ? where message_id = ? and state = ?"
        do {
            let failedValue = Int32(STMessage.State.failed.rawValue)
            let sendingValue = Int32(STMessage.State.sending.rawValue)
            let count = try connection.update(sql: sql, values: failedValue, id, sendingValue)
            return count == 1
        } catch {
            logger.warn("update message state failed", error)
            return false
        }
    }
    
    func updateMessagesAsFailed(){
        let sql = "update message set state = ? where state = ?"
        do {
            let failedValue = Int32(STMessage.State.failed.rawValue)
            let sendingValue = Int32(STMessage.State.sending.rawValue)
            try connection.update(sql: sql, values: failedValue, sendingValue)
        } catch {
            logger.warn("update messages' state failed", error)
        }
    }
    
    func updateMessageAsSending(id: String){
        let sql = "update message set state = ?, timestamp = ? where message_id = ?"
        do {
            let sendingValue = Int32(STMessage.State.sending.rawValue)
            let timestamp = Date().milliseconds
            try connection.update(sql: sql, values: sendingValue, timestamp, id)
        } catch {
            logger.warn("update message state failed", error)
        }
    }
    
    func messagesCount(chatId: String) -> Int{
        let sql = "select count(1) from message where chat_id = ?"
        var count = 0
        do{
            let resultSet = try connection.query(sql: sql, values: chatId)
            resultSet.next()
            let value = try resultSet.getInt64(0)
            count = Int(value)
        }catch{
            logger.warn("get message count failed", error)
        }
        return count
    }
    
    func messages(chatId: String, offset: Int = 0, count: Int = 10) -> [STMessage]{
        let sql = "select * from message where chat_id = ? order by timestamp asc, id asc limit ? offset ?"
        var messages: [STMessage] = []
        do{
            let offset = Int32(offset)
            let limit = Int32(count)
            let resultSet = try connection.query(sql: sql, values: chatId, limit, offset)
            while resultSet.next(){
                let message = try STMessage(resultSet)
                if var message = message{
                    complement(message: &message)
                    messages.append(message)
                }
            }
        }catch{
            logger.warn("fetch messages failed", error)
        }
        return messages
    }
    
    func setMessagesRead(chatId: String, selfJid: String){
        let sql = "update message set state = ? where chat_id = ? and state = ? and sender != ?"
        do{
            let readValue = Int32(STMessage.State.read.rawValue)
            let sentValue = Int32(STMessage.State.sent.rawValue)
            try connection.update(sql: sql, values: readValue, chatId, sentValue, selfJid)
        }catch{
            logger.warn("set messages read failed", error)
        }
    }
    
    func fetchMessage(id: String) -> STMessage?{
        let sql = "select * from message where message_id = ?"
        do {
            let resultSet = try connection.query(sql: sql, values: id)
            if resultSet.next(){
                let message = try STMessage(resultSet)
                if var message = message{
                    complement(message: &message)
                    return message
                }
            }
        } catch {
            logger.warn("fetch message faield", error)
        }
         return nil
    }
    
    func updateMessageContent(id: String, content: String){
        let sql = "update message set content = ? where message_id = ?"
        do {
            try connection.update(sql: sql, values: content, id)
        } catch {
            logger.warn("update message content failed", error)
        }
    }
    
    private func complement(message: inout STMessage){
        message.resetDirection(with: userState.jid)
    }
}
