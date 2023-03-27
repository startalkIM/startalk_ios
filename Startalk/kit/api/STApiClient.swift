//
//  STApiClient.swift
//  Startalk
//
//  Created by lei on 2023/3/6.
//

import Foundation

class STApiClient{
    let logger = STLogger(STApiClient.self)

    lazy var navigationManager = STKit.shared.navigationManager
    lazy var userState = STKit.shared.userState
    lazy var xmppClient = STKit.shared.xmppClient
    
    let httpClient: STHttpClient
    
    init() {
        self.httpClient = STHttpClient()
    }
    
    var baseUrl: String{
        navigationManager.apiUrl
    }
    
    func buildUrl(path: String, params: [String: Any?] = [:]) -> URL{
        return httpClient.buildUrl(baseUrl: baseUrl, path: path, params: params)
    }
    
    func request<T: Codable>(_ url: URL, completionHandler: @escaping (STApiResult<T>) -> Void){
        httpClient.request(url) { [self] response, error in
            handle(response, error: error, url: url, completionHandler: completionHandler)
        }
    }
    
    func post<T: Codable>(_ url: URL, entity: Codable, completionHandler: @escaping (STApiResult<T>) -> Void){
        httpClient.post(url, entity: entity) { [self] response, error in
            handle(response, error: error, url: url, completionHandler: completionHandler)
        }
    }
    
    private func handle<T: Codable>(_ response: STApiResponse<T>?, error: Error?, url: URL,  completionHandler: @escaping (STApiResult<T>) -> Void){
        if let error = error {
            logger.error("Http request error", error)
            fail(error.localizedDescription, completionHandler)
            return
        }
        
        guard let response = response else{
            logger.error("Response data is nil of url \(url)")
            fail("network_request_failed".localized, completionHandler)
            return
        }
       
        let result: STApiResult<T>
        if response.ret{
            let data = response.data
            if let data = data{
                result = .response(data)
            }else{
                result = .success
            }
        }else{
            let message = response.errmsg
            result = .failure(message)
        }
        completionHandler(result)
    }
    
    private func fail<T>(_ message: String, _ completionHandler: @escaping (STApiResult<T>) -> Void){
        let result = STApiResult<T>.failure(message)
        completionHandler(result)
    }
}

extension STApiClient{
    static let COOKIE_CKEY_NAME = "q_ckey"
    static let COOKIE_USER_NAME = "u"
    
    func setCookies(){
        setUserCookie()
        setCKeyCookie()
    }
    
    func setUserCookie(){
        let username = userState.username
        httpClient.setCookie(url: baseUrl, name: Self.COOKIE_USER_NAME, value: username)
    }
    
    func setCKeyCookie(){
        let username = userState.username
        let xmppToken = xmppClient.token
        let time: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
        
        let rawCode = "\(xmppToken)\(time)"
        var code = StringUtil.md5(data: rawCode.data(using: .utf8)!)
        code = code.uppercased()
        
        let text = "u=\(username)&k=\(code)&t=\(time)"
        let value = text.data(using: .utf8)!.base64EncodedString()
        
        httpClient.setCookie(url: baseUrl, name: Self.COOKIE_CKEY_NAME, value: value)
    }
}
