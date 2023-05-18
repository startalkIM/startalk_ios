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
    let groupManager: GroupManager
    let messageManager: STMessageManager
    let chatManager: ChatManager
    
    let databaseManager: DatabaseManager
    let filesManager: FilesManager
    
    let apiClient: STApiClient
    let xmppClient: STXmppClient
    let fileUploadClient: FileUploadClient
    
    let notificationManager: STNotificationManager
    let notificationCenter: STNotificationCenter
    
    private init(){
        identifiers = STIdentifiers()
        appStateManager = STAppStateManager()
        userState = STUserState()
        serviceManager = STServiceManager()
        loginManager = STLoginManager()
        userManager = UserManager()
        groupManager = GroupManager()
        messageManager = STMessageManager()
        chatManager = ChatManager()
        
        databaseManager = DatabaseManager()
        filesManager = FilesManager()
        
        apiClient = STApiClient()
        xmppClient = STXmppClient()
        fileUploadClient = FileUploadClient()
        
        notificationManager = STNotificationManager()
        notificationCenter = STNotificationCenter()
    }
}
