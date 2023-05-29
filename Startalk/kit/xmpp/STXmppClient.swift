//
//  STXMPPClient.swift
//  Startalk
//
//  Created by lei on 2023/3/19.
//

import XMPPClient
import UIKit

class STXmppClient{
    let logger = STLogger(STXmppClient.self)
    
    lazy var serviceManager = STKit.shared.serviceManager
    lazy var userState = STKit.shared.userState
    lazy var identifiers = STKit.shared.identifiers
    lazy var appStateManager = STKit.shared.appStateManager
    lazy var messageManager = STKit.shared.messageManager
    
    var stream: XCStream?
    var jid: XCJid = .empty
    var token = ""
    var clientType: XCClientType = .ios
    
    func connnect(){
        guard self.stream == nil else{ return }
        
        let host = serviceManager.host
        let port: UInt16 = UInt16(serviceManager.port)
        let domain = serviceManager.domain
    
        let username = userState.username
        let password = makeXmppPassword()
        let resource = makeXmppResource()
        
        let configuration = XCServiceConfiguration(host: host, port: port, domain: domain, username: username, password: password, resource: resource)
        
        let stream = XCStream(config: configuration)
        stream.delegate = self
        stream.start()
        
        self.stream = stream
    }
    
    func disconnect(){
        guard let stream = stream else { return }
        
        stream.stop()
        self.stream = nil
    }
    
   
    func sendMessage(_ message: XCMessage){
        guard let stream = stream else { return }
        
        stream.sendMessage(message)
    }
    
}

extension STXmppClient{
    static let APP_VERSION_KEY = "CFBundleShortVersionString"
    static let APP_DEFAULT_VERSION = "1.0"

    private func makeXmppPassword() -> String{
        var password: String? = nil
        
        let username = userState.username
        let userToken = userState.token
        let deviceUid = identifiers.deviceUid
        let dict = ["nauth":
                        [
                            "p": userToken,
                            "u": username,
                            "mk": deviceUid
                        ]
                    ]
        let data = try? JSONSerialization.data(withJSONObject: dict)
        if let data = data{
            password = String(data: data, encoding: .utf8)
        }
        if let password = password{
            return password
        }else{
            fatalError("make password failed")
        }
    }
    
    private func makeXmppResource() -> String{        
        let platform = identifiers.systemName
        let systemVersion = identifiers.systemVersion
        let deviceName = identifiers.deviceName
        let deviceUid = identifiers.deviceUid
        let appVersion = identifiers.appVersion
       
        return "V[\(appVersion)]_P[\(platform)]_S[\(systemVersion)]_D[\(deviceName)]_ID[\(deviceUid)]"
    }
}

extension STXmppClient: XCStreamDelegate{
    
    func stream(_ stream: XMPPClient.XCStream, stateUpdated state: XCStream.State) {
        logger.info("state changed to \(state)")
        
        if case .established(let jid, let token) = state{
            self.jid = jid
            self.token = token
            
            stream.setPresent()
            appStateManager.setConnected()
        }
    }
    
    func stream(_ stream: XMPPClient.XCStream, receivedMessage message: XCMessage) {
        messageManager.receivedMessage(message)
    }
    
    func stream(_ stream: XMPPClient.XCStream, receivedEvent event: XCEvent) {
        switch event.type{
        case .messageSent(let messageId, _):
            messageManager.receviedMessageStateEvent(messageId, state: .sent)
        @unknown default:
            break
        }
    }
}
