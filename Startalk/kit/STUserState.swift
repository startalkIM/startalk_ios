//
//  UserState.swift
//  Startalk
//
//  Created by lei on 2023/3/8.
//

import Foundation

class STUserState{
    static private let LOG_STATE_KEY = "logged_in"
    static private let USERNAME_KEY = "username"
    static private let USER_TOKEN_KEY = "user_token"
    
    lazy var appStateManager = STKit.shared.appStateManager

    let defaults = UserDefaults.standard
    
    var isLoggedIn: Bool = false
    var username: String = ""
    var token: String = ""

    init() {
        isLoggedIn = pickLogState() ?? false
        username = pickUsername() ?? ""
        token = pickToken() ?? ""
    }
    
    func setLoggedIn(username: String, token: String){
        isLoggedIn = true
        storeLogState(true)
        
        self.username = username
        storeUsername(username)
        
        self.token = token
        storeToken(token)
        
        appStateManager.setLoggedIn()
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
