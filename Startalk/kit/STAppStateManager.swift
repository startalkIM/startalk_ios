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
    lazy var databaseManager = STKit.shared.databaseManager
    lazy var notificationManager = STKit.shared.notificationManager
    lazy var notificationCenter = STKit.shared.notificationCenter
    
    var state: STAppState = .connecting
    
    func initialize(){
        notificationCenter.observeAppWillBecomeActive(self, handler: appWillBecomeActive)
        notificationCenter.observeAppDidEnterBackground(self, handler: appDidEnterBackground)
        
        userState.initialize()
        
        appWillBecomeActive()
    }
    
    private func appWillBecomeActive(){
        if userState.isLoggedIn{
            connect()
        }else{
            setState(.login)
        }
    }
    
    func appDidEnterBackground(){
        disconnect(to: .inactive)
        databaseManager.save()
    }
    
    private func connect(){
        setState(.connecting)
        
        xmppClient.connnect()
        notificationManager.setup()
    }
    
    private func load(){
        setState(.loading)

        userState.jid = xmppClient.jid
        apiClient.setCookies()
        messageManager.synchronizeMessages()
        notificationManager.appConnected()
    }
    
    private func run(){
        setState(.running)
    }
    
    private func disconnect(to state: STAppState){
        assert(state == .login || state == .inactive)
        setState(state)
        
        xmppClient.disconnect()
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

extension STAppStateManager{
    var isConnected: Bool {
        state == .loading || state == .running
    }
}

enum STAppState{
    case inactive
    case login
    case connecting
    case loading
    case running
}
