//
//  URLUtil.swift
//  Startalk
//
//  Created by lei on 2023/3/7.
//

import Foundation

class URLUtil{
    
    static func equals(_ value1: String, _ value2: String) -> Bool{
        let url1 = URLComponents(string: value1)
        let url2 = URLComponents(string: value2)
        guard let url1 = url1, let url2 = url2 else{
            return false
        }
        if url1.scheme != url2.scheme{
            return false
        }
        if url1.host != url2.host{
            return false
        }
        
        let port1 = port(url1)
        let port2 = port(url2)
        if port1 != port2{
            return false
        }
        if url1.path != url2.path{
            return false
        }
        
        let params1 = Set<URLQueryItem>(url1.queryItems ?? [])
        let params2 = Set<URLQueryItem>(url2.queryItems ?? [])
        if params1 != params2 {
            return false
        }
        
        return true
    }
    
    static func port(_ url: URLComponents) -> Int?{
        var port = url.port
        if port == nil, var scheme = url.scheme{
            scheme = scheme.lowercased()
            if scheme == "http"{
                port = 80
            }else if scheme == "https"{
                port = 443
            }
        }
        return port
    }
    
    static func normalize(_ value: String) -> String{
        let components = URLComponents(string: value)
        guard var components = components else{
            return value
        }
        var queryItems = components.queryItems
        queryItems?.sort(by: { item1, item2 in
            item1.name < item2.name
        })
        components.queryItems = queryItems
        components.fragment = nil
        return components.string ?? ""
    }
}
