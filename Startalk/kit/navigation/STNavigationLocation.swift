//
//  STNavigationLocation.swift
//  Startalk
//
//  Created by lei on 2023/3/5.
//

import Foundation

struct STNavigationLocation: Codable{
    var id: Int
    var name: String
    var value: String
    
    static let empty = Self(id: 0, name: "", value: "")
    
}
