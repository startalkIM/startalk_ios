//
//  User.swift
//  Startalk
//
//  Created by lei on 2023/4/16.
//

import Foundation
import CoreData

struct User{
    var username: String
    var domain: String
    var name: String?
    var gender: Gender?
    var photo: String?
    var bio: String?
    
    init(username: String, domain: String, name: String? = nil, gender: Gender? = nil, photo: String? = nil, bio: String? = nil) {
        self.username = username
        self.domain = domain
        self.name = name
        self.gender = gender
        self.photo = photo
        self.bio = bio
    }
}

extension User{
    
    @discardableResult
    func makeUserMO(context: NSManagedObjectContext) -> UserMO {
        let userMo = UserMO(context: context)
        userMo.username = username
        userMo.domain = domain
        userMo.name = name
        let genderValue = gender?.rawValue
        if let genderValue = genderValue{
            userMo.gender = Int16(genderValue)
        }
        userMo.photo = photo
        userMo.bio = bio
        return userMo
    }
}

extension UserMO{
    
    var user: User{
        let genderValue = Int(gender)
        let gender = Gender(rawValue: genderValue)
        return User(username: username!, domain: domain!, name: name, gender: gender, photo: photo, bio: bio)
    }
}

enum Gender: Int{
    case female = 0
    case male = 1
    case other = 2
}
