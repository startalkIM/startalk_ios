//
//  STApiClient.swift
//  Startalk
//
//  Created by lei on 2023/3/6.
//

import Foundation

class STApiClient{
    static let DEFAULT_ERROR_MESSAGE = "unknown"
    let logger = STLogger(STApiClient.self)

    lazy var serviceManager = STKit.shared.serviceManager
    lazy var userState = STKit.shared.userState
    lazy var xmppClient = STKit.shared.xmppClient
    
    let httpClient: STHttpClient
    
    init() {
        self.httpClient = STHttpClient()
    }
    
    var baseUrl: String{
        serviceManager.apiUrl
    }
    
    var pushUrl: String{
        serviceManager.pushUrl
    }
    
    func buildUrl(path: String, params: [String: Any?] = [:]) -> URL{
        return httpClient.buildUrl(baseUrl: baseUrl, path: path, params: params)
    }
    
    func buildPushUrl(path: String, params: [String: Any?] = [:]) -> URL {
        return httpClient.buildUrl(baseUrl: pushUrl, path: path, params: params)
    }
    
    func request<T: Codable>(_ url: URL) async -> STApiResult<T>{
        let task = Task<STApiResponse<T>?, Error>{
            try await httpClient.request(url)
        }
        return await handle(task, url: url)
    }
    
    func post<T: Codable>(_ url: URL, entity: Codable) async -> STApiResult<T>{
        let task = Task<STApiResponse<T>?, Error>{
            try await httpClient.post(url, entity: entity)
        }
        return await handle(task, url: url)
    }
    
    private func handle<T>(_ task: Task<STApiResponse<T>?, Error>, url: URL) async -> STApiResult<T>{
        do{
            let response = try await task.value
            
            guard let response = response else{
                logger.error("Response data is nil of url \(url)")
                return STApiResult<T>.failure("network_request_failed".localized)
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
                let message = response.errmsg ?? Self.DEFAULT_ERROR_MESSAGE
                result = .failure(message)
            }
            return result
        }catch{
            logger.error("Http request error of \(url)", error)
            return STApiResult<T>.failure(error.localizedDescription)
        }
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
        httpClient.setCookie(url: pushUrl, name: Self.COOKIE_CKEY_NAME, value: value)
    }
}
