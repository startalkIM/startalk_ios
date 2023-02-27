//
//  STLoginManager.swift
//  Startalk
//
//  Created by lei on 2023/2/26.
//

import Foundation
import Combine

class STLoginManager{
    static let BASE_URL = "https://i.startalk.im/newapi"
    static let LOGIN_PATH = "/nck/qtlogin.qunar"
    
    let logger = Logger(STLoginManager.self)
    
    let httpClient = STHttpClient(BASE_URL)
    let identifiers: STIdentifiers
    let navigationManager: STNavigationManager
    
    @Published var isLoggedIn: Bool = false
    
    init(identifiers: STIdentifiers, navigationManager: STNavigationManager) {
        self.identifiers = identifiers
        self.navigationManager = navigationManager
    }
    
    func login(username: String, password: String, completionHandler: @escaping (Bool, String) -> Void){
        let domain = navigationManager.domain
        let encryptedPassword = RSAUtil.encrpyt(password)
        guard let encryptedPassword = encryptedPassword else{
            let message = "encrypting password failed"
            logger.error(message)
            fatalError(message)
        }
        let deviceUid = identifiers.deviceUid
        let request = STLoginRequest(u: username, h: domain, p: encryptedPassword, mk: deviceUid)
        
        let url = httpClient.buildUrl(path: Self.LOGIN_PATH)
        httpClient.post(url, entity: request) { [self] (result: STHttpResult<STLoginResponse>) -> Void in
            switch result{
            case .response(let response):
                print(response)
                isLoggedIn = true
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
