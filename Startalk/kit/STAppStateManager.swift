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
    lazy var databaseManager2 = STKit.shared.databaseManager2
    lazy var notificationManager = STKit.shared.notificationManager
    lazy var notificationCenter = STKit.shared.notificationCenter
    
    var state: STAppState = .login
    
    func initialize(){
        notificationCenter.observeAppWillBecomeActive(self, handler: appWillBecomeActive)
        notificationCenter.observeAppDidEnterBackground(self, handler: appDidEnterBackground)
        
        userState.initialize()
        
        if userState.isLoggedIn{
            setLoggedIn()
        }
    }
    
    func setLoggedIn(){
        postLogin()
        connect()
    }
    
    func appWillBecomeActive(){
        if state == .inactive{
            connect()
        }
    }
    
    func setConnected(){
        load()
    }
    
    func setLoaded(){
        run()
    }
    
    func appDidEnterBackground(){
        disconnect(to: .inactive)
        databaseManager.save()
    }
    
    func setLoggedOut(){
        disconnect(to: .login)
    }
}

extension STAppStateManager{
    
    private func postLogin(){
        databaseManager2.initialize()
    }
    
    private func connect(){
        setState(.connecting)
        
        notificationManager.setup()
        xmppClient.connnect()
    }
    
    private func load(){
        setState(.loading)

        userState.setJid()
        apiClient.setCookies()
        notificationManager.appConnected()

        messageManager.synchronizeMessages()
    }
    
    private func run(){
        setState(.running)
    }
    
    private func disconnect(to state: STAppState){
        assert(state == .login || state == .inactive)
        setState(state)
        
        xmppClient.disconnect()
    }
    
    private func setState(_ state: STAppState){
        self.state = state
        notificationCenter.notifyAppStateChanged(state)
    }
}


extension STAppStateManager{
    var isConnected: Bool {
        state == .loading || state == .running
    }
}

enum STAppState{
    case login
    case connecting
    case loading
    case running
    case inactive
}
