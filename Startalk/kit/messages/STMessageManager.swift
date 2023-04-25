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
    lazy var userState = STKit.shared.userState
    lazy var xmppClient = STKit.shared.xmppClient
    
    var messageLoader = STHistoryMessagesLoader()

    var messageStorage = STMessageStorage()
    var chatStorage = STChatStorage()
    
    //MARK: synchronize with server
    func synchronizeMessages(){
        Task{
            let user = userState.jid.bare
            let lastTime = messageStorage.lastMessageTime(user: user)
            let messages = await messageLoader.fetch(since: lastTime)
            addHistoryMessages(messages)
            appStateManager.setLoaded()
        }
    }
    
    private func addHistoryMessages(_ messages: [STMessage]){
        if messages.isEmpty{ return }
        
        var messages = messages
        for i in messages.indices{
            messages[i].supplement(with: userState.jid)
        }
        
        appendMessages(messages)
    }
    
    
    //MARK: receive message from xmpp client
    
    func receivedMessage(_ message: XCMessage){
        var message = STMessage.receive(message)
        message.supplement(with: userState.jid)
        appendMessages([message])
    }
    
    func receviedMessageSentEvent(_ messsageId: String, timestamp: Int64){
        //let isLast = messageStorage.updateMessage(withId: messsageId, state: .sent)
        messageStorage.updateMessage(withId: messsageId, state: .sent)
        let idState = STMessageIdState(id: messsageId, state: .sent)
        notificationCenter.notifyMessageStateChanged(idState)
        
//        if isLast{
//            notificationCenter.notifyChatListChanged()
//        }
    }
    
    //MARK: send message
    func sendTextMessage(to chat: STChat, content: String){
        let to = XCJid(chat.id)
        guard let to = to else{ return }
        
        let header = XCHeader(from: userState.jid, to: to, isGroup: chat.isGroup)
        let id = StringUtil.makeUUID()
        let content = XCTextMessageContent(value: content)
        let timestamp = Date().milliseconds
        let message = XCMessage(header: header, id: id, type: .text, content: content, clientType: xmppClient.clientType, timestamp: timestamp)
        
        var stMessage: STMessage = .send(message)
        stMessage.supplement(with: userState.jid)
        appendMessages([stMessage])

        xmppClient.sendMessage(message)
        
    }
    
    
    
    //MARK: private common functions
    private func appendMessages(_ messages: [STMessage]){
        messageStorage.addMessages(messages)
        notificationCenter.notifyMessagesAppended(messages)
        chatStorage.addMessages(messages)
        notificationCenter.notifyChatListChanged()
    }
    
    
    
    //MARK: set messages read
    func setMessagesRead(_ chat: STChat){
        messageStorage.setMessagesRead(chatId: chat.id, isGroup: chat.isGroup)
        chatStorage.clearUnreadCount(chat.id)
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
