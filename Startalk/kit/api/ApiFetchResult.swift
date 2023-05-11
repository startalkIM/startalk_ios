//
//  STHttpResult.swift
//  Startalk
//
//  Created by lei on 2023/2/27.
//

import Foundation

enum ApiFetchResult<T>{
    case success(T)
    case failure(String)
}

enum ApiRequestResult{
    case success
    case failure(String)
}

struct Empty: Codable{
    
}
