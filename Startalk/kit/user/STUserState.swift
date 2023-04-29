//
//  UserState.swift
//  Startalk
//
//  Created by lei on 2023/3/8.
//

import Foundation
import XMPPClient

class STUserState{
    static private let LOG_STATE_KEY = "logged_in"
    static private let USERNAME_KEY = "username"
    static private let USER_TOKEN_KEY = "user_token"
    
    let logger = STLogger(STUserState.self)
    
    lazy var appStateManager = STKit.shared.appStateManager
    lazy var serviceManager = STKit.shared.serviceManager
    lazy var userManager = STKit.shared.userManager
    lazy var xmppClient = STKit.shared.xmppClient

    let defaults = UserDefaults.standard
    
    var isLoggedIn: Bool = false
    var username: String = ""
    var token: String = ""
    
    var activityId: Int = 0
    
    var jid: XCJid = .empty

    func initialize() {
        isLoggedIn = pickLogState() ?? false
        username = pickUsername() ?? ""
        token = pickToken() ?? ""
        
        if isLoggedIn{
            pickActivityId()
        }
    }
    
    func setLoggedIn(username: String, token: String){
        isLoggedIn = true
        storeLogState(true)
        
        self.username = username
        storeUsername(username)
        
        self.token = token
        storeToken(token)
        
        pickActivityId()
        
        appStateManager.setLoggedIn()
    }
    
    func setJid(){
        jid = xmppClient.jid
    }
    
    func setLoggedOut(){
        isLoggedIn = false
        storeLogState(false)
        
        self.username = ""
        storeUsername(nil)
        
        self.token = ""
        storeToken(nil)
        
        appStateManager.setLoggedOut()
    }
}

extension STUserState{
    func pickLogState() -> Bool?{
        defaults.bool(forKey: Self.LOG_STATE_KEY)
    }
    
    func pickUsername() -> String?{
        defaults.string(forKey: Self.USERNAME_KEY)
    }
    
    func pickToken() -> String?{
        defaults.string(forKey: Self.USER_TOKEN_KEY)
    }
    
    func storeLogState(_ value: Bool){
        defaults.set(value, forKey: Self.LOG_STATE_KEY)
    }
    
    func storeUsername(_ value: String?){
        defaults.set(value, forKey: Self.USERNAME_KEY)
    }
    
    func storeToken(_ value: String?){
        defaults.set(value, forKey: Self.USER_TOKEN_KEY)
    }
}


extension STUserState{
    func pickActivityId() {
        let domain = serviceManager.domain
        let activity = userManager.fetchOrAddActivity(username: username, domain: domain)
        activityId = activity.id
    }
    
}
