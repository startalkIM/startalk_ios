//
//  STMessageManager.swift
//  Startalk
//
//  Created by lei on 2023/3/20.
//

import Foundation
import XMPPClient

class STMessageManager{
    lazy var appStateManager = STKit.shared.appStateManager
    lazy var notificationCenter = STKit.shared.notificationCenter
    lazy var xmppClient = STKit.shared.xmppClient
    
    var messageLoader = STHistoryMessagesLoader()

    var messageStorage = STMessageStorage()
    var chatStorage = STChatStorage()
    
    //MARK: synchronize with server
    func synchronizeMessages(){
        let lastTime = messageStorage.lastMessageTimestamp
        messageLoader.fetch(since: lastTime){ [self] messages in
            addHistoryMessages(messages)
            appStateManager.setLoaded()
        }
    }
    
    private func addHistoryMessages(_ messages: [STMessage]){
        if messages.isEmpty{ return }
        
        let userJid = xmppClient.jid.bare
        var messages = messages
        for i in 0..<messages.count{
            if messages[i].from == userJid{
                messages[i].direction = .send
            }else{
                messages[i].direction = .receive
            }
        }
        
        appendMessages(messages)
    }
    
    
    //MARK: receive message from xmpp client
    
    func receivedMessage(_ message: XCMessage){
        var message = STMessage.receive(message)
        if message.isGroup{
            let realFrom = message.realFrom
            let from = message.from
            
            message.to = from
            if let realFrom = realFrom{
                message.from = realFrom
            }
        }
        appendMessages([message])
    }
    
    func receviedMessageSentEvent(_ messsageId: String, timestamp: Int64){
        messageStorage.updateMessage(withId: messsageId, state: .sent)
        let idState = STMessageIdState(id: messsageId, state: .sent)
        notificationCenter.notifyMessageStateChanged(idState)
        
        let updated = chatStorage.updateMessage(withId: messsageId, state: .sent)
        if updated{
            notificationCenter.notifyChatListChanged()
        }
    }
    
    //MARK: send message
    func sendTextMessage(to chatId: String, content: String){
        let chat = chatStorage.chat(withId: chatId)
        guard let chat = chat else { return }
        let to = XCJid(chatId)
        guard let to = to else{ return }
        
        let header = XCHeader(from: xmppClient.jid, to: to, isGroup: chat.isGroup)
        let id = StringUtil.makeUUID()
        let content = XCTextMessageContent(value: content)
        let timestamp = Date().milliseconds
        let message = XCMessage(header: header, id: id, type: .text, content: content, clientType: xmppClient.clientType, timestamp: timestamp)
        
        xmppClient.sendMessage(message)
        
        appendMessages([.send(message)])
    }
    
    
    
    //MARK: private common functions
    private func appendMessages(_ messages: [STMessage]){
        let count = messageStorage.addMessages(messages)
        if count == 0{
            return
        }
        notificationCenter.notifyMessagesAppended(messages)
        chatStorage.addMessages(messages)
        notificationCenter.notifyChatListChanged()
    }
}

extension STMessageManager{
    
    func makeChatDataSource() -> STChatDataSource{
        return STChatDataSource(storage: chatStorage)
    }
    
    func makeMessageDataSource(chatId: String) -> STMessageDataSource{
        return STMessageDataSource(storage: messageStorage, chatId: chatId)
    }
}
