//
//  STNotificationManager.swift
//  Startalk
//
//  Created by lei on 2023/4/8.
//

import UIKit

class STNotificationManager{
    static let SEND_TOKEN_PATH = "/push/qtapi/token/setpersonmackey.qunar"
    
    static let TOKEN_KEY = "STARTALK_NOTIFICATION_TOKEN"
    static let STATUS_KEY = "STARTALK_NOTIFICATION_STATUS"
    static let TOKEN_SENT_KEY = "STARTALK_NOTIFICATION_TOEKN_SENT"
    
    let defaults = UserDefaults.standard
    lazy var identifiers = STKit.shared.identifiers
    lazy var userSate = STKit.shared.userState
    lazy var appStateManager = STKit.shared.appStateManager
    lazy var serviceManager = STKit.shared.serviceManager
    lazy var apiClient = STKit.shared.apiClient
    
    var token: String?
    var status: UNAuthorizationStatus = .notDetermined
    var tokenSent = false
    
    init(){
        token = pickToken()
        status = pickStatus() ?? .notDetermined
        tokenSent = pickTokenSent() ?? false
    }
    
    func setup(){
        if token == nil{
            requestToken()
        }
        if status == .notDetermined{
            requestPermission()
        }
    }
    
    func requestPermission(){
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { [self] settings in
            let status = settings.authorizationStatus
            if status == .notDetermined{
                center.requestAuthorization(options: [.badge, .sound, .alert, .carPlay]) { [self] granted, _ in
                    if granted {
                        setStatus(.authorized)
                    }else{
                        setStatus(.denied)
                    }
                }
            }else{
                setStatus(status)
            }
        }
    }
    
    func setStatus(_ value: UNAuthorizationStatus){
        status = value
        storeStatus(value)
        if status == .authorized{
            trySendToken()
        }
    }
    
    func requestToken(){
        let application = UIApplication.shared
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }
    }
    
    func receiveToken(_ data: Data){
        let token = StringUtil.hex(data: data)
        
        self.token = token
        storeToken(token)
        
        trySendToken()
    }
    
    func appConnected(){
        trySendToken()
    }
    
    func clearToken(){
        self.token = nil
        self.removeToken()
        
        sendClearToken()
    }
    
    private func trySendToken(){
        if status == .authorized, let token = token, appStateManager.isConnected, !tokenSent{
            sendToken(token)
        }
    }
    
    private func sendToken(_ token: String){
        let username = userSate.username
        let domain = serviceManager.domain
        let deviceName = identifiers.deviceName
        let appId = identifiers.appId
        let systemName = identifiers.systemName
        let appVersion = identifiers.appVersion
        let params = ["username": username, "domain": domain, "mac_key": token, "platname": deviceName, "pkgname": appId, "os": systemName, "version": appVersion]
        
        let url = apiClient.buildPushUrl(path: Self.SEND_TOKEN_PATH, params: params)
        apiClient.request(url) { [self] (result: STApiResult<Empty>) -> Void in
            if case .success = result{
              setTokenSent(true)
            }else if case let .failure(reason) = result{
                print("send token failed: ", reason)
            }
        }
    }
    
    private func setTokenSent(_ value: Bool){
        tokenSent = true
        storeTokenSent(true)
    }
    
    private func sendClearToken(){
        
    }
   
}

extension STNotificationManager{
    private func pickToken() -> String?{
        defaults.string(forKey: Self.TOKEN_KEY)
    }
    
    private func storeToken(_ value: String){
        defaults.set(value, forKey: Self.TOKEN_KEY)
    }
    
    private func removeToken(){
        defaults.removeObject(forKey: Self.TOKEN_KEY)
    }
    
    private func pickStatus() -> UNAuthorizationStatus?{
        let value = defaults.integer(forKey: Self.STATUS_KEY)
        return UNAuthorizationStatus(rawValue: value)
    }
    
    private func storeStatus(_ status: UNAuthorizationStatus){
        let value = status.rawValue
        defaults.set(value, forKey: Self.STATUS_KEY)
    }
    
    private func removeStatus(){
        defaults.removeObject(forKey: Self.STATUS_KEY)
    }
    
    private func pickTokenSent() -> Bool?{
        defaults.bool(forKey: Self.TOKEN_SENT_KEY)
    }
    
    private func storeTokenSent(_ value: Bool){
        defaults.set(value, forKey: Self.TOKEN_SENT_KEY)
    }
    
    private func removeTokenSent(){
        defaults.removeObject(forKey: Self.TOKEN_SENT_KEY)
    }
}
