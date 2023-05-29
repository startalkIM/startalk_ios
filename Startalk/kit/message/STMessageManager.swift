//
//  STMessageManager.swift
//  Startalk
//
//  Created by lei on 2023/3/20.
//

import Foundation
import XMPPClient
import UIKit

class STMessageManager{
    static let MESSAGE_TIMEOUT: TimeInterval = 10
    static let SHOW_TIMESTAMP_INTERVAL: TimeInterval = 60
    let logger = STLogger(STMessageManager.self)
    
    lazy var appStateManager = STKit.shared.appStateManager
    lazy var notificationCenter = STKit.shared.notificationCenter
    lazy var userState = STKit.shared.userState
    lazy var xmppClient = STKit.shared.xmppClient
    lazy var chatManager = STKit.shared.chatManager
    lazy var fileStorage = STKit.shared.filesManager.storage
    lazy var fileUploaderClient = STKit.shared.fileUploadClient

    
    var messageLoader = STHistoryMessagesLoader()

    var storage = STMessageStorage()
        
    //MARK: synchronize with server
    func synchronizeMessages(){
        storage.updateMessagesAsFailed()
        Task{
            let user = userState.jid.bare
            let lastTime = storage.lastMessageTime(user: user)
            let messages = await messageLoader.fetch(since: lastTime)
            addHistoryMessages(messages)
            appStateManager.setLoaded()
        }
    }
    
    private func addHistoryMessages(_ messages: [STMessage]){
        if messages.isEmpty{ return }
        
        appendMessages(messages)
    }
    
    
    //MARK: receive message from xmpp client
    
    func receivedMessage(_ message: XCMessage){
        let header = message.header
        var message = STMessage.receive(message)
        if header.isGroup{
            message.to = header.from
            message.from = header.realFrom!
            message.resetDirection(with: userState.jid)
        }else{
            if header.isCarbonCopied{
                message.from = header.to
                message.to = header.from
                message.direction = .send
            }
        }
        appendMessages([message])
    }
    
    //MARK: send message
    func sendTextMessage(to chat: STChat, text: String){
        let content = XCTextMessageContent(value: text)
        let message = perpareMessage(to: chat, content: content, type: .text)
        sendMessage(message)
    }
    
    func sendImageMessage(to chat: STChat, image: UIImage){
        if let data = image.pngData(){
            var name: String?
            do {
                name = try fileStorage.storePersistent(data, type: FilesManager.PNG_TYPE)
            }catch{
                logger.warn("store image failed", error)
            }
            guard let name = name else{ return }
            let type = FilesManager.PNG_TYPE
            let size = image.size
            
            var content = XCImageMessageContent(source: " ", width: Float(size.width), height: Float(size.height))
            var message = perpareMessage(to: chat, content: content, type: .text, localFile: name)
            
            fileUploaderClient.uploadImage(data: data, name: name, type: type){ [self] result in
                if case .success(let source) = result{
                    content.source = source
                    storage.updateMessageContent(id: message.id, content: content.value)
                    message.content = content
                    sendMessage(message)
                }else{
                    logger.warn("upload image failed")
                }
            }
        }
    }
    
    func perpareMessage(to chat: STChat, content: XCMessageContent, type: XCMessageType, localFile: String? = nil) -> STMessage{
        let to = XCJid(chat.id)!
        
        let header = XCHeader(from: userState.jid, to: to, isGroup: chat.isGroup)
        let id = StringUtil.makeUUID()
        let timestamp = Date().milliseconds
        let xcMessage = XCMessage(header: header, id: id, type: type, content: content, clientType: xmppClient.clientType, timestamp: timestamp)
        
        let message: STMessage = .send(xcMessage, localFile: localFile)
        appendMessages([message])
        return message
    }
    
    func sendMessage(_ message: STMessage){
        xmppClient.sendMessage(message.xcMessage)
        DispatchQueue.global().asyncAfter(deadline: .now() + Self.MESSAGE_TIMEOUT){ [self] in
            markMessageSendingFailed(message.id)
        }
    }
    
    
    func resend(id: String){
        let message = storage.fetchMessage(id: id)
        guard let message = message else { return }
        storage.updateMessageAsSending(id: message.id)
        sendMessage(message)
        notificationCenter.notifyMessageResend(id)
    }
    
    //MARK: message state change
    func receviedMessageStateEvent(_ messsageId: String, state: STMessage.State){
        storage.updateMessage(withId: messsageId, state: state)
        let idState = STMessageIdState(id: messsageId, state: state)
        notificationCenter.notifyMessageStateChanged(idState)
    }
    
    func markMessageSendingFailed(_ messsageId: String){
        let success = storage.tryUpdateMessageAsFailed(id: messsageId)
        if success{
            let idState = STMessageIdState(id: messsageId, state: .failed)
            notificationCenter.notifyMessageStateChanged(idState)
        }
    }
    
    //MARK: private common functions
    private func appendMessages(_ messages: [STMessage]){
        let messages = complementShowTimestamp(messages)
        storage.addMessages(messages)
        notificationCenter.notifyMessagesAppended(messages)
        chatManager.addMessages(messages)
        notificationCenter.notifyChatListChanged()
    }
    
    private func complementShowTimestamp(_ messages: [STMessage]) -> [STMessage]{
        var messages = messages
        let ids = Array(Set(messages.map { $0.chatId}))
        let chats = chatManager.fetchChats(ids: ids)
        var dict: [String: Date] = [:]
        chats.forEach { dict[$0.id] = $0.timestamp}
        
        for i in messages.indices{
            var message = messages[i]
            let chatId = message.chatId
            let lastTimestamp = dict[chatId] ?? Date(milliseconds: 0)
            if message.timestamp.timeIntervalSince(lastTimestamp) > Self.SHOW_TIMESTAMP_INTERVAL {
                message.showTimestamp = true
                messages[i] = message
            }
            dict[chatId] = message.timestamp
        }
        return messages
    }
    
    //MARK: set messages read
    func setMessagesRead(_ chat: STChat){
        storage.setMessagesRead(chatId: chat.id, selfJid: userState.jid.bare)
        chatManager.clearUnreadCount(chat.id)
    }
}

extension STMessageManager{
    
    func makeMessageDataSource(chatId: String) -> STMessageDataSource{
        return STMessageDataSource(storage: storage, chatId: chatId)
    }
}
