//
//  STApiClient.swift
//  Startalk
//
//  Created by lei on 2023/3/6.
//

import Foundation

class STApiClient{
    static let shared: STApiClient = STApiClient()
    lazy var navigationManager = STKit.shared.navigationManager
    
    let logger = STLogger(STApiClient.self)
    
    let httpClient: STHttpClient
    
    private init() {
        self.httpClient = STHttpClient()
    }
    
    func buildUrl(path: String, params: [String: Any?] = [:]) -> URL{
        let baseUrl = navigationManager.navigation.apiUrl
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
