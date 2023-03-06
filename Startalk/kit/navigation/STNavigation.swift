//
//  STNavigation.swift
//  Startalk
//
//  Created by lei on 2023/3/6.
//

import Foundation

struct STNavigation: Codable{
    var domain: String
    var host: String
    var port: Int
    var apiUrl: String
    
    init(domain: String, host: String, port: Int, apiUrl: String) {
        self.domain = domain
        self.host = host
        self.port = port
        self.apiUrl = apiUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.domain = try container.decode(String.self, forKey: .domain)
        self.host = try container.decode(String.self, forKey: .host)
        self.port = try container.decode(Int.self, forKey: .port)
        self.apiUrl = try container.decode(String.self, forKey: .apiUrl)
    }
    
        
    static let `default` = STNavigation(domain: "startalk.im", host: "i.startalk.im", port: 5202, apiUrl: "https://i.startalk.im/newapi")

}
