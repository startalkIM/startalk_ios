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
    let serviceManager: STServiceManager
    let loginManager: STLoginManager
    let userManager: UserManager
    let messageManager: STMessageManager
    
    let databaseManager: STDatabaseManager
    
    let apiClient: STApiClient
    let xmppClient: STXmppClient
    
    let notificationManager: STNotificationManager
    let notificationCenter: STNotificationCenter
    
    private init(){
        identifiers = STIdentifiers()
        appStateManager = STAppStateManager()
        userState = STUserState()
        serviceManager = STServiceManager()
        loginManager = STLoginManager()
        userManager = UserManager()
        messageManager = STMessageManager()
        
        databaseManager = STDatabaseManager()
        
        apiClient = STApiClient()
        xmppClient = STXmppClient()
        
        notificationManager = STNotificationManager()
        notificationCenter = STNotificationCenter()
    }
}
