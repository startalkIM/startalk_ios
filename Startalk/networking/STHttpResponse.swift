//
//  STHttpResponse.swift
//  Startalk
//
//  Created by lei on 2023/2/27.
//

import Foundation

struct STHttpResponse<T: Codable>: Codable{
    var ret: Bool
    var errcode: Int
    var errmsg: String
    var data: T?
}
