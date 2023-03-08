//
//  StringUtil.swift
//  Startalk
//
//  Created by lei on 2023/3/6.
//

import Foundation

class StringUtil{
    
    static func isEmpty(_ string: String?) -> Bool{
        return string == nil || string == ""
    }
    
    static func isNotEmpty(_ string: String?) -> Bool{
        return string != nil && string != ""
    }
    
    static func makeUUID() -> String{
        var uuid = UUID().uuidString
        uuid.removeAll { char in
            char == "-"
        }
        return uuid
    }
}
