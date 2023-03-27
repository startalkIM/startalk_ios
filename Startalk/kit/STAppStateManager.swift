//
//  STAppState.swift
//  Startalk
//
//  Created by lei on 2023/2/28.
//

import Foundation

class STAppStateManager{
    lazy var apiClient = STKit.shared.apiClient
    lazy var xmppClient = STKit.shared.xmppClient
    lazy var messageManager = STKit.shared.messageManager
    
    var state: STAppState = .inactive
    
    func setLoggedIn(){
        state = .connnecting
        
        xmppClient.connnect()
    }
    
    func setConnected(){
        state = .loading
        
        apiClient.setCookies()
        messageManager.synchronizeMessages()
    }
}

enum STAppState{
    case inactive
    case login
    case connnecting
    case loading
    case running
}
