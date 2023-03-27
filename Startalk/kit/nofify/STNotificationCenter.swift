//
//  STNotificationCenter.swift
//  Startalk
//
//  Created by lei on 2023/3/20.
//

import Foundation

class STNotificationCenter{
    let center = NotificationCenter.default
    var holders: [Notification.Name: [(AnyObject, NSObjectProtocol)]] = [: ]
    let queue = OperationQueue()
    
    init() {
        queue.name = "st notification center queue"
    }
    
    private func addObserver(_ observer: AnyObject, name: Notification.Name, handler: @escaping (Notification) -> Void){
        let currentHandle = removeHandle(observer: observer, name: name)
        if let currentHandle = currentHandle{
            center.removeObserver(currentHandle, name: name, object: nil)
        }
        let handle = center.addObserver(forName: name, object: nil, queue: queue, using: handler)
        addHandle(handle, name: name, observer: observer)
    }
    
    private func removeObserver(_ observer: AnyObject, name: Notification.Name){
        let handle = removeHandle(observer: observer, name: name)
        if let handle = handle{
            center.removeObserver(handle, name: name, object: nil)
        }
    }
    
    private func addHandle(_ handle: NSObjectProtocol, name: Notification.Name, observer: AnyObject){
        if holders[name] == nil{
            holders[name] = []
        }
        holders[name]!.append((observer, handle))
    }
    
    private func removeHandle(observer: AnyObject, name: Notification.Name) -> NSObjectProtocol?{
        let index = holders[name]?.firstIndex{ $0.0 === observer }
        if let index = index{
            let pair = holders[name]?.remove(at: index)
            return pair?.1
        }else{
            return nil
        }
    }
}


extension STNotificationCenter{
    
    //MARK: message appended
    func observeMessagesAppended(_ observer: AnyObject, handler: @escaping ([STMessage]) -> Void){
        addObserver(observer, name: .STMessageAppended) { notification in
            if let messages = notification.object as? [STMessage]{
                handler(messages)
            }
        }
    }
    
    func unobserveMessagesAppended(_ observer: AnyObject){
        removeObserver(observer, name: .STMessageAppended)
    }
    
    func notifyMessagesAppended(_ messages: [STMessage]){
        center.post(name: .STMessageAppended, object: messages)
    }
    
    //MARK: message state changed

    func observeMessageStateChanged(_ observer: AnyObject, handler: @escaping (STMessageIdState) -> Void){
        addObserver(observer, name: .STMessageStateChanged) { notification in
            if let idState = notification.object as? STMessageIdState{
                handler(idState)
            }
        }
    }
    
    func unobserveMessageStateChanged(_ observer: AnyObject){
        removeObserver(observer, name: .STMessageStateChanged)
    }
    
    func notifyMessageStateChanged(_ idState: STMessageIdState){
        center.post(name: .STMessageStateChanged, object: idState)
    }
    
    //MARK: chat list changed
    func observeChatListChanged(_ observer: AnyObject, handler: @escaping () -> Void){
        addObserver(observer, name: .STChatListChanged) { _ in
            handler()
        }
    }
    
    func unobserveChatListChanged(_ observer: AnyObject){
        removeObserver(observer, name: .STChatListChanged)
    }
    
    func notifyChatListChanged(){
        center.post(name: .STChatListChanged, object: nil)
    }
}

extension Notification.Name{
    
    static let STMessageAppended = Notification.Name("ST_message_appended")
    
    static let STMessageStateChanged = Notification.Name("ST_message_state_changed")
    
    static let STChatListChanged = Notification.Name("ST_chat_list_changed")
    


}
