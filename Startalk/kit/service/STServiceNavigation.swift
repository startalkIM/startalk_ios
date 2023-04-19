//
//  STServiceNavigation.swift
//  Startalk
//
//  Created by lei on 2023/3/6.
//

import Foundation

struct STServiceNavigation{
    var domain: String
    var host: String
    var port: Int
    var apiUrl: String
    var pushUrl: String
    var fileUrl: String
    
    init(domain: String, host: String, port: Int, apiUrl: String, pushUrl: String, fileUrl: String) {
        self.domain = domain
        self.host = host
        self.port = port
        self.apiUrl = apiUrl
        self.pushUrl = pushUrl
        self.fileUrl = fileUrl
        
    }
        
    static let `default` = STServiceNavigation(
        domain: "qtalk",
        host: "qtalk.app",
        port: 5202,
        apiUrl: "https://uk.startalk.im/newapi",
        pushUrl: "https://uk.startalk.im/package",
        fileUrl: "https://uk.startalk.im"
    )
}

extension STServiceNavigation: Codable{
    
    enum DecodingKeys: CodingKey{
        case baseaddess
    }
    
    enum BaseAddressKeys: CodingKey{
        case domain
        case xmpp
        case protobufPort
        case httpurl
        case javaurl
        case fileurl
    }
    
    init(from decoder: Decoder) throws {
        let rawContainer = try? decoder.container(keyedBy: DecodingKeys.self)
        if let rawContainer = rawContainer, rawContainer.contains(.baseaddess){
            let container = try rawContainer.nestedContainer(keyedBy: BaseAddressKeys.self, forKey: .baseaddess)
            self.domain = try container.decode(String.self, forKey: .domain)
            self.host = try container.decode(String.self, forKey: .xmpp)
            self.port = try container.decode(Int.self, forKey: .protobufPort)
            self.apiUrl = try container.decode(String.self, forKey: .httpurl)
            self.pushUrl = try container.decode(String.self, forKey: .javaurl)
            self.fileUrl = try container.decode(String.self, forKey: .fileurl)
        }else{
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.domain = try container.decode(String.self, forKey: .domain)
            self.host = try container.decode(String.self, forKey: .host)
            self.port = try container.decode(Int.self, forKey: .port)
            self.apiUrl = try container.decode(String.self, forKey: .apiUrl)
            self.pushUrl = try container.decode(String.self, forKey: .pushUrl)
            self.fileUrl = try container.decode(String.self, forKey: .fileUrl)
        }
        
    }
}
