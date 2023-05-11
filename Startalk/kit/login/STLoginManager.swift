//
//  STLoginManager.swift
//  Startalk
//
//  Created by lei on 2023/2/26.
//

import Foundation
import Combine

class STLoginManager{
    static let LOGIN_PATH = "/nck/qtlogin.qunar"
    
    let logger = STLogger(STLoginManager.self)
    
    lazy var identifiers = STKit.shared.identifiers
    lazy var apiClient = STKit.shared.apiClient
    lazy var serviceManager = STKit.shared.serviceManager
    lazy var userState = STKit.shared.userState
    lazy var appStateManager = STKit.shared.appStateManager
        
    func login(username: String, password: String) async -> (Bool, String){
        let domain = serviceManager.navigation.domain
        let encryptedPassword = RSAUtil.encrpyt(password)
        guard let encryptedPassword = encryptedPassword else{
            let message = "encrypting password failed"
            logger.error(message)
            fatalError(message)
        }
        let deviceUid = identifiers.deviceUid
        let request = STLoginRequest(u: username, h: domain, p: encryptedPassword, mk: deviceUid)
        
        let url = apiClient.buildUrl(path: Self.LOGIN_PATH)
        let result: ApiFetchResult<STLoginResponse> = await apiClient.fetch(url, entity: request)
        switch result{
        case .success(let response):
    
            userState.setLoggedIn(username: response.u, token: response.t)
            return (true, "")
            
        case .failure(let message):
            return(false, message)
        }
    }
}

struct STLoginRequest: Codable{
    var u: String    ///username
    var h: String    ///domain
    var p: String    ///rsa encrypted password
    var mk: String   ///device id
}


struct STLoginResponse: Codable{
    var h: String  ///domain
    var u: String  ///username
    var t: String  ///token
}
