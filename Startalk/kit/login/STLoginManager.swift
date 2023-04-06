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
    lazy var navigationManager = STKit.shared.navigationManager
    lazy var userState = STKit.shared.userState
    lazy var appStateManager = STKit.shared.appStateManager
        
    func login(username: String, password: String, completionHandler: @escaping (Bool, String) -> Void){
        let domain = navigationManager.navigation.domain
        let encryptedPassword = RSAUtil.encrpyt(password)
        guard let encryptedPassword = encryptedPassword else{
            let message = "encrypting password failed"
            logger.error(message)
            fatalError(message)
        }
        let deviceUid = identifiers.deviceUid
        let request = STLoginRequest(u: username, h: domain, p: encryptedPassword, mk: deviceUid)
        
        let url = apiClient.buildUrl(path: Self.LOGIN_PATH)
        apiClient.post(url, entity: request) { [self] (result: STApiResult<STLoginResponse>) -> Void in
            switch result{
            case .response(let response):
        
                userState.setLoggedIn(username: response.u, token: response.t)
                completionHandler(true, "")
                
            case .failure(let message):
                completionHandler(false, message)
            default:
                break
            }
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
