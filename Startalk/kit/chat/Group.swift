//
//  ChatGroup.swift
//  Startalk
//
//  Created by lei on 2023/4/16.
//

import Foundation
import CoreData

struct Group{
    static let DEFAULT_NAME = "Group"
    var xmppId: String
    var name: String
    var photo: String?
    
    init(xmppId: String, name: String, photo: String? = nil) {
        self.xmppId = xmppId
        self.name = name
        self.photo = photo
    }
}

extension Group{
    init(resultSet: SQLiteResultSet) throws {
        xmppId = try resultSet.getString("xmpp_id")!
        name = try resultSet.getString("name") ?? Self.DEFAULT_NAME
        photo = try resultSet.getString("photo")
    }
}
