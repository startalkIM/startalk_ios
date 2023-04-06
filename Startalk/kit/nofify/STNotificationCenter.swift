//
//  STNotificationCenter.swift
//  Startalk
//
//  Created by lei on 2023/3/20.
//

import Foundation
import UIKit

class STNotificationCenter{
    let center = NotificationCenter.default
    var holders: [Notification.Name: [Handle]] = [: ]
    let queue = OperationQueue()
    
    init() {
        queue.name = "startalk notification center queue"
    }
    
    private func addObserver(_ observer: AnyObject, name: Notification.Name, object: Any? = nil,handler: @escaping (Notification) -> Void){
        let currentHandle = removeHandle(observer: observer, name: name)
        if let currentHandle = currentHandle{
            center.removeObserver(currentHandle, name: name, object: nil)
        }
        let token = center.addObserver(forName: name, object: nil, queue: queue, using: handler)
        addHandle(token, name: name, observer: observer, object: object)
    }
    
    private func removeObserver(_ observer: AnyObject, name: Notification.Name){
        let token = removeHandle(observer: observer, name: name)
        if let token = token{
            center.removeObserver(token, name: name, object: nil)
        }
    }
    
    private func addHandle(_ token: NSObjectProtocol, name: Notification.Name, observer: AnyObject, object: Any?){
        if holders[name] == nil{
            holders[name] = []
        }
        let handle = Handle(observer: observer, token: token, object: object)
        holders[name]!.append(handle)
    }
    
    private func removeHandle(observer: AnyObject, name: Notification.Name) -> NSObjectProtocol?{
        let index = holders[name]?.firstIndex{ $0.observer === observer }
        if let index = index{
            let handle = holders[name]?.remove(at: index)
            return handle?.token
        }else{
            return nil
        }
    }
}

extension STNotificationCenter{
    struct Handle{
        var observer: AnyObject
        var token: NSObjectProtocol
        var object: Any?
    }
}

extension STNotificationCenter{
    //MARK: application activity
    func observeAppWillBecomeActive(_ observer: AnyObject, handler: @escaping () -> Void){
        addObserver(observer, name: UIApplication.willEnterForegroundNotification) { _ in
            handler()
        }
    }
    
    func observeAppWillResignActive(_ observer: AnyObject, handler: @escaping () -> Void){
        addObserver(observer, name: UIApplication.willResignActiveNotification) { _ in
            handler()
        }
    }
    
    
    
    //MARK: app state
    
    func observeAppStateChanged(_ observer: AnyObject, handler: @escaping (STAppState) -> Void){
        addObserver(observer, name: .STAppStateChanged) { notification in
            if let state = notification.object as? STAppState{
                handler(state)
            }
        }
    }
    
    func notifyAppStateChanged(_ state: STAppState){
        center.post(name: .STAppStateChanged, object: state)
    }
    
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
    static let STAppStateChanged = Notification.Name("startalk_app_state_changed")
    
    static let STMessageAppended = Notification.Name("startalk_message_appended")
    
    static let STMessageStateChanged = Notification.Name("startalk_message_state_changed")
    
    static let STChatListChanged = Notification.Name("startalk_chat_list_changed")

}
