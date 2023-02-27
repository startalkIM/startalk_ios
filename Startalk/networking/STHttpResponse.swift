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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ret = try container.decode(Bool.self, forKey: STHttpResponse<T>.CodingKeys.ret)
        self.errcode = try container.decode(Int.self, forKey: STHttpResponse<T>.CodingKeys.errcode)
        self.errmsg = try container.decode(String.self, forKey: STHttpResponse<T>.CodingKeys.errmsg)
        self.data = try? container.decodeIfPresent(T.self, forKey: STHttpResponse<T>.CodingKeys.data)
    }
}
