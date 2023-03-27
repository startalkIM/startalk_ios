//
//  STKit.swift
//  Startalk
//
//  Created by lei on 2023/2/26.
//

import Foundation

class STKit{
    static let shared = STKit()
    
    let identifiers: STIdentifiers
    let appStateManager: STAppStateManager
    let userState: STUserState
    let navigationManager: STNavigationManager
    let loginManager: STLoginManager
    let messageManager: STMessageManager
    
    let apiClient: STApiClient
    let xmppClient: STXmppClient
    
    let notificationCenter: STNotificationCenter
    
    private init(){
        identifiers = STIdentifiers()
        appStateManager = STAppStateManager()
        userState = STUserState()
        navigationManager = STNavigationManager()
        loginManager = STLoginManager()
        messageManager = STMessageManager()
        
        apiClient = STApiClient()
        xmppClient = STXmppClient()
        
        notificationCenter = STNotificationCenter()
    }
    
    
}
