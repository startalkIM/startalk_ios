//
//  STHttpClient.swift
//  Startalk
//
//  Created by lei on 2023/2/26.
//

import Foundation

class STHttpClient{
    static let HTTP_METHOD_POST = "POST"
    static let HEADER_FIELD_CONTENT_TYPE = "Content-Type"
    static let CONTENT_TYPE_JSON = "application/json"
    
    let logger = Logger(STHttpClient.self)
    let urlSession: URLSession = URLSession(configuration: .default)
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    let baseUrl: String
    
    init(_ baseUrl: String) {
        self.baseUrl = baseUrl
    }

    func buildUrl(path: String, params: [String: Any?] = [:]) -> URL{
        var urlComponents = URLComponents(string: baseUrl + path)!
        var  queryItems: [URLQueryItem] = []
        for (key, value) in params {
            if let value = value{
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                queryItems.append(queryItem)
            }
        }
        urlComponents.queryItems = queryItems
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")
        return urlComponents.url!
    }
    
    func request<T: Codable>(_ url: URL, completionHandler: @escaping (STHttpResult<T>) -> Void){
        let dataTask = urlSession.dataTask(with: url) { [self] data, response, error in
            handle(data: data, error: error, url: url, completionHandler: completionHandler)
        }
        dataTask.resume()
    }
    
    func post<T: Codable>(_ url: URL, entity: Codable, completionHandler: @escaping (STHttpResult<T>) -> Void){
        
        let bodyData = try! encoder.encode(entity)
        
        var request = URLRequest(url: url)
        request.httpMethod = Self.HTTP_METHOD_POST
        request.httpBody = bodyData
        request.setValue(Self.CONTENT_TYPE_JSON, forHTTPHeaderField: Self.HEADER_FIELD_CONTENT_TYPE)
        
        let dataTask = urlSession.dataTask(with: request) { [self] data, _, error in
            handle(data: data, error: error, url: url, completionHandler: completionHandler)
        }
        
        dataTask.resume()
    }
    
    private func handle<T: Codable>(data: Data?, error: Error?, url: URL,  completionHandler: @escaping (STHttpResult<T>) -> Void){
        if let error = error {
            logger.error("Http request error", error)
            fail(error.localizedDescription, completionHandler)
            return
        }
        
        guard let data = data else{
            logger.error("Response data is nil of url \(url)")
            fail("network_request_failed".localized, completionHandler)
            return
        }
       
        do{
            let response = try decoder.decode(STHttpResponse<T>.self, from: data)
            let result: STHttpResult<T>
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
        }catch{
            logger.error("Hint error parsing response of url \(url)", error)
        }
    }
    
    private func fail<T>(_ message: String, _ completionHandler: @escaping (STHttpResult<T>) -> Void){
        let result = STHttpResult<T>.failure(message)
        completionHandler(result)
    }
}
