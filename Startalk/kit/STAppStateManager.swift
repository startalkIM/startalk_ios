//
//  STAppState.swift
//  Startalk
//
//  Created by lei on 2023/2/28.
//

import Foundation

class STAppStateManager{
    lazy var userState = STKit.shared.userState
    lazy var apiClient = STKit.shared.apiClient
    lazy var xmppClient = STKit.shared.xmppClient
    lazy var messageManager = STKit.shared.messageManager
    lazy var notificationCenter = STKit.shared.notificationCenter
    
    var state: STAppState = .connecting
    
    func initialize(){
        notificationCenter.observeAppWillBecomeActive(self, handler: appWillBecomeActive)
        notificationCenter.observeAppWillResignActive(self, handler: appWillResignActive)
        appWillBecomeActive()
    }
    
    private func appWillBecomeActive(){
        if userState.isLoggedIn{
            connect()
        }else{
            setState(.login)
        }
    }
    
    func appWillResignActive(){
        disconnect(to: .inactive)
    }
    
    private func connect(){
        xmppClient.connnect()
        
        setState(.connecting)
    }
    
    private func load(){
        apiClient.setCookies()
        messageManager.synchronizeMessages()
        
        setState(.loading)
    }
    
    private func run(){
        setState(.running)
    }
    
    private func disconnect(to state: STAppState){
        xmppClient.disconnect()
        
        assert(state == .login || state == .inactive)
        setState(state)
    }
    
    func setState(_ state: STAppState){
        self.state = state
        notificationCenter.notifyAppStateChanged(state)
    }
}

extension STAppStateManager{
    func setLoggedIn(){
       connect()
    }
    
    func setConnected(){
        load()
    }
    
    func setLoaded(){
        run()
    }
    
    func setLoggedOut(){
        disconnect(to: .login)
    }
}

enum STAppState{
    case inactive
    case login
    case connecting
    case loading
    case running
}
