//
//  Logger.swift
//  XMPPClient
//
//  Created by lei on 2023/2/17.
//

import Foundation

class Logger<T>{
    let type: T.Type
    var level: Level = .info
    
    init(_ type: T.Type){
        self.type = type
    }
    
    func debug(_ text: String, _ error: Error? = nil){
        log(text, error: error, level: .debug)
    }
    
    func info(_ text: String, _ error: Error? = nil){
        log(text, error: error, level: .info)
    }
    
    func warn(_ text: String,  _ error: Error? = nil){
        log(text, error: error, level: .warn)
    }
    
    func error(_ text: String,  _ error: Error? = nil){
        log(text, error: error, level: .error)
    }
    
    private func log(_ text: String, error: Error?, level: Level){
        if level.rawValue >= self.level.rawValue{
            print("\(type): \(text)", error ?? "")
        }
    }
    
    enum Level: Int{
        case debug
        case info
        case warn
        case error
    }
}
