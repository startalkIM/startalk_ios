//
//  StringUtil.swift
//  Startalk
//
//  Created by lei on 2023/3/6.
//

import Foundation
import CryptoKit

class StringUtil{
    
    static func isEmpty(_ string: String?) -> Bool{
        return string == nil || string == ""
    }
    
    static func isNotEmpty(_ string: String?) -> Bool{
        return string != nil && string != ""
    }
    
    
    static func validContent(_ string: String?) -> String?{
        if let string = string{
            if !string.isEmpty{
                let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
                if !string.isEmpty{
                    return string
                }
            }
        }
        return nil
    }
    
    static func makeUUID() -> String{
        var uuid = UUID().uuidString
        uuid.removeAll { char in
            char == "-"
        }
        return uuid
    }
    
    static func md5(data: Data) -> String{
        let digest = Insecure.MD5.hash(data: data)
        return digest.map {String(format: "%02hhx", $0)}.joined()
    }
    
    static func sha256(data: Data) -> String{
        let digest = SHA256.hash(data: data)
        return digest.map {String(format: "%02hhx", $0)}.joined()
    }
    
    static func hex(data: Data) -> String{
        return data.map {String(format: "%02hhx", $0)}.joined()
    }
}
