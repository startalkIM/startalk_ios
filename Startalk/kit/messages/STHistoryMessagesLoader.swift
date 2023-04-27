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
    lazy var serviceManager = STKit.shared.serviceManager
    lazy var xmppClient = STKit.shared.xmppClient
    
    
    func fetch(since: Date?) async -> [STMessage]{
        var messages: [STMessage] = []
        
        async let asyncPrivatMessages = fetch(since: since, path: Self.PRIVATE_PATH)
        async let asyncGroupMessages = fetch(since: since, path: Self.GROUP_PATH)
        
        let privatMessages = await asyncPrivatMessages ?? []
        messages.append(contentsOf: privatMessages)
        
        let groupMessages = await asyncGroupMessages ?? []
        messages.append(contentsOf: groupMessages)
        
        for i in messages.indices{
            messages[i].resetDirection(with: userState.jid)
        }
        
        return messages
    }
    
    private func fetch(since: Date?, path: String) async -> [STMessage]?{
        
        let user = userState.username
        let domain = serviceManager.domain
        let time: Int64
        if let since = since{
            time = since.milliseconds
        }else{
            time = Date(timeIntervalSinceNow: -Self.DEFAULT_INTERVAL).milliseconds
        }
        let num = Self.DEFAULT_COUNT
        
        let entity = RequestEntity(user: user, domain: domain, host: domain, time: time, num: num)
        let url = apiClient.buildUrl(path: path)
        
        let result: STApiResult<[STMessage]> = await apiClient.post(url, entity: entity)
        
        switch result{
        case .response(let messages):
            return messages
        case .failure(let reason):
            logger.warn("load private history messages failed: \(reason)")
            return nil
        default:
            return nil // won't reach here
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


