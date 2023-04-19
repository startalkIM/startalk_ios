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
    
    let logger = STLogger(STHttpClient.self)
    let urlSession: URLSession = URLSession(configuration: .default)
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    func buildUrl(baseUrl: String, path: String, params: [String: Any?] = [:]) -> URL{
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
    
    func request<T: Codable>(_ url: URL) async throws -> T?{
        let (data, _) = try await urlSession.data(from: url)
        return try handle(data: data)
    }
    
    func post<T: Codable>(_ url: URL, entity: Codable) async throws -> T?{
        
        let bodyData = try! encoder.encode(entity)
        
        var request = URLRequest(url: url)
        request.httpMethod = Self.HTTP_METHOD_POST
        request.httpBody = bodyData
        request.setValue(Self.CONTENT_TYPE_JSON, forHTTPHeaderField: Self.HEADER_FIELD_CONTENT_TYPE)
        
        let (data, _) = try await urlSession.data(for: request)
        print(url, String(data: data, encoding: .utf8))
        return try handle(data: data)
    }
    
    private func handle<T: Codable>(data: Data?) throws -> T?{
        guard let data = data else{
            return nil
        }
        return try decoder.decode(T.self, from: data)
    }
}

extension STHttpClient{
    static let COOKIE_DEFAULT_EXPIRE_INTERVAL: TimeInterval = 60 * 60 * 24 * 30
    
    func setCookie(url: String, name: String, value: String){
        let storage = HTTPCookieStorage.shared
        
        guard let url = URL(string: url) else { return }
        
        guard let host = url.host else { return }
        let path = url.path
        let expireDate = Date(timeIntervalSinceNow: Self.COOKIE_DEFAULT_EXPIRE_INTERVAL)
        
        let properties: [HTTPCookiePropertyKey : Any] = [
            .domain: host,
            .path: path,
            
            .name: name,
            .value: value,
            
            .expires: expireDate,
        ]
        
        let cookie = HTTPCookie(properties: properties)
        if let cookie = cookie{
            storage.setCookie(cookie)
        }
    }
}
