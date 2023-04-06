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
    
    var semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    var isPrivateLoaded: Bool = false
    var isGroupLoaded: Bool = false
    var messages: [STMessage] = []
    
    func fetch(since: Date?, completion: @escaping ([STMessage]) -> Void ){
        isPrivateLoaded = false
        isGroupLoaded = false
        messages = []
        
        fetch(since: since, path: Self.PRIVATE_PATH) { [self] messages in
            semaphore.wait()
            
            var messages = messages
            messages.indices.forEach{ messages[$0].isGroup = false}
            self.messages.append(contentsOf: messages)
            isPrivateLoaded = true
            if isGroupLoaded{
                completion(self.messages)
            }
            
            semaphore.signal()
        }
        
        fetch(since: since, path: Self.GROUP_PATH) { [self] messages in
            semaphore.wait()
            
            var messages = messages
            messages.indices.forEach{ messages[$0].isGroup = true}
            self.messages.append(contentsOf: messages)
            isGroupLoaded = true
            if isPrivateLoaded{
                completion(self.messages)
            }
            
            semaphore.signal()
        }
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


