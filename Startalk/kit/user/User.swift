//
//  User.swift
//  Startalk
//
//  Created by lei on 2023/4/16.
//

import Foundation
import CoreData

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
}

enum Gender: Int{
    case female = 0
    case male = 1
    case other = 2
}
