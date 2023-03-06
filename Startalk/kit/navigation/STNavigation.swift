//
//  STNavigation.swift
//  Startalk
//
//  Created by lei on 2023/3/6.
//

import Foundation

struct STNavigation{
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
        
    static let `default` = STNavigation(
        domain: "startalk.im",
        host: "i.startalk.im",
        port: 5202,
        apiUrl: "https://i.startalk.im/newapi"
    )
}

extension STNavigation: Codable{
    
    enum DecodingKeys: CodingKey{
        case baseaddess
    }
    
    enum BaseAddressKeys: CodingKey{
        case domain
        case xmpp
        case protobufPort
        case httpurl
    }
    
    init(from decoder: Decoder) throws {
        let rawContainer = try? decoder.container(keyedBy: DecodingKeys.self)
        if let rawContainer = rawContainer, rawContainer.contains(.baseaddess){
            let container = try rawContainer.nestedContainer(keyedBy: BaseAddressKeys.self, forKey: .baseaddess)
            self.domain = try container.decode(String.self, forKey: .domain)
            self.host = try container.decode(String.self, forKey: .xmpp)
            self.port = try container.decode(Int.self, forKey: .protobufPort)
            self.apiUrl = try container.decode(String.self, forKey: .httpurl)
        }else{
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.domain = try container.decode(String.self, forKey: .domain)
            self.host = try container.decode(String.self, forKey: .host)
            self.port = try container.decode(Int.self, forKey: .port)
            self.apiUrl = try container.decode(String.self, forKey: .apiUrl)
        }
        
    }
}
