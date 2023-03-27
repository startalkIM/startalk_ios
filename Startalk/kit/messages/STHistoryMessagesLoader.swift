//
//  STMessageFetcher.swift
//  Startalk
//
//  Created by lei on 2023/3/20.
//

import Foundation

class STHistoryMessagesLoader{
    let logger = STLogger(STHistoryMessagesLoader.self)
    
    static let PRIVATE_PATH = "/gethistory.qunar"
    static let GROUP_PATH = "/getmuchistory.qunar"
    static let DEFAULT_COUNT = 1000
    static let DEFAULT_INTERVAL: TimeInterval = 60 * 60 * 24 * 7
    
    lazy var apiClient = STKit.shared.apiClient
    lazy var userState = STKit.shared.userState
    lazy var navigationManager = STKit.shared.navigationManager
    lazy var xmppClient = STKit.shared.xmppClient
    
    func fetchPrivate(since: Date?, completion: @escaping ([STMessage]) -> Void){
        fetch(since: since, path: Self.PRIVATE_PATH, completion: completion)
    }
    
    func fetchGroup(since: Date?, completion: @escaping ([STMessage]) -> Void){
        fetch(since: since, path: Self.GROUP_PATH, completion: completion)

    }
    
    private func fetch(since: Date?, path: String, completion: @escaping ([STMessage]) -> Void){
        
        let user = userState.username
        let domain = navigationManager.domain
        let time: Int64
        if let since = since{
            time = since.milliseconds
        }else{
            time = Date(timeIntervalSinceNow: -Self.DEFAULT_INTERVAL).milliseconds
        }
        let num = Self.DEFAULT_COUNT
        
        let entity = RequestEntity(user: user, domain: domain, host: domain, time: time, num: num)
        let url = apiClient.buildUrl(path: path)
        
        apiClient.post(url, entity: entity) { [self](result: STApiResult<[STMessage]>) -> Void in
            switch result{
            case .response(let messages):
                completion(messages)
            case .failure(let reason):
                logger.warn("load private history messages failed: \(reason)")
            default:
                break
            }
        }
    }
}

extension STHistoryMessagesLoader{
    
    struct RequestEntity: Codable{
        var user: String
        var domain: String
        var host: String
        var time: Int64
        var num: Int
    }
}


