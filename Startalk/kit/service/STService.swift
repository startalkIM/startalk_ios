//
//  STService.swift
//  Startalk
//
//  Created by lei on 2023/3/5.
//

import Foundation

struct STService: Codable{
    var id: Int
    var name: String
    var location: String
    
    static let empty = Self(id: 0, name: "", location: "")
    
}
