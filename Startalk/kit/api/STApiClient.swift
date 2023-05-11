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
    
    func request(_ url: URL) async -> ApiRequestResult{
        let response: Response<Empty> = await handle(url: url) {
            try await httpClient.request(url)
        }
        return makeRequestResult(response: response)
    }
    
    func request(_ url: URL, entity: Codable) async -> ApiRequestResult{
        let response: Response<Empty> = await handle(url: url) {
            try await httpClient.post(url, entity: entity)
        }
        return makeRequestResult(response: response)
    }
    
    func fetch<T: Codable>(_ url: URL) async -> ApiFetchResult<T>{
        let response: Response<T> = await handle(url: url) {
            try await httpClient.request(url)
        }
        return makeFetchResult(response: response, url: url)
    }
    
    func fetch<T: Codable>(_ url: URL, entity: Codable) async -> ApiFetchResult<T>{
        let response: Response<T> = await handle(url: url) {
            try await httpClient.post(url, entity: entity)
        }
        return makeFetchResult(response: response, url: url)
    }
    
    private func handle<T>(url: URL, fetch: () async throws -> STApiResponse<T>) async -> Response<T>{
        do{
            let response = try await fetch()
            
            let success = response.ret
            let data = response.data
            let message = response.errmsg ?? Self.DEFAULT_ERROR_MESSAGE
            return Response(success: success, data: data, message: message)
        }catch{
            logger.error("Http request error of \(url)", error)
            return Response(success: false, data: nil, message: error.localizedDescription)
        }
    }
    
    private func makeRequestResult(response: Response<Empty>) -> ApiRequestResult{
        if response.success{
            return .success
        }else{
            return .failure(response.message)
        }
    }
    
    private func makeFetchResult<T>(response: Response<T>, url: URL) -> ApiFetchResult<T>{
        if response.success{
            if let data = response.data{
                return .success(data)
            }else{
                let message = "response data is emtpy or nil"
                logger.warn("\(url): \(message)")
                return .failure(message)
            }
        }else{
            return .failure(response.message)
        }
    }
    
    private struct Response<T>{
        var success: Bool
        var data: T?
        var message: String
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
        let domain = serviceManager.domain
        let xmppToken = xmppClient.token
        let time: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
        
        let rawCode = "\(xmppToken)\(time)"
        var code = StringUtil.md5(data: rawCode.data(using: .utf8)!)
        code = code.uppercased()
        
        let text = "u=\(username)&k=\(code)&t=\(time)&d=\(domain)"
        let value = text.data(using: .utf8)!.base64EncodedString()
        
        httpClient.setCookie(url: baseUrl, name: Self.COOKIE_CKEY_NAME, value: value)
        httpClient.setCookie(url: pushUrl, name: Self.COOKIE_CKEY_NAME, value: value)
    }
}
