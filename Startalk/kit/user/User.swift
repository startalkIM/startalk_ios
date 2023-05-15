//
//  User.swift
//  Startalk
//
//  Created by lei on 2023/4/16.
//

import Foundation
import XMPPClient

struct User{
    var id: Int
    var username: String
    var domain: String
    var name: String?
    var gender: Gender?
    var photo: String?
    var bio: String?
    
    init(id: Int = 0, username: String, domain: String, name: String? = nil, gender: Gender? = nil, photo: String? = nil, bio: String? = nil) {
        self.id = id
        self.username = username
        self.domain = domain
        self.name = name
        self.gender = gender
        self.photo = photo
        self.bio = bio
    }
    
    var xmppId: XCJid{
        XCJid(name: username, domain: domain)
    }
    
}

enum Gender: Int{
    case female = 0
    case male = 1
    case other = 2
}

extension User{
    
    init?(resultSet: SQLiteResultSet) throws{
        let idValue = try resultSet.getInt32("id")
        id = Int(idValue)
        username = try resultSet.getString("username")!
        domain = try resultSet.getString("domain")!
        name = try resultSet.getString("name")
        let genderValue = try resultSet.getInt32("gender")
        gender = Gender(rawValue: Int(genderValue))
        photo = try resultSet.getString("photo")
        bio = try resultSet.getString("bio")
    }
}
