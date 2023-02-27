//
//  STHttpResult.swift
//  Startalk
//
//  Created by lei on 2023/2/27.
//

import Foundation

enum STHttpResult<T>{
    case success
    case response(T)
    case failure(String)
}