//
//  STKit.swift
//  Startalk
//
//  Created by lei on 2023/2/26.
//

import Foundation

class STKit{
    static let shared = STKit()
    
    let identifiers: STIdentifiers
    let appState: STAppState
    let loginManager: STLoginManager
    let navigationManager: STNavigationManager
    
    private init(){
        identifiers = STIdentifiers()
        appState = STAppState()
        navigationManager = STNavigationManager()
        loginManager = STLoginManager()
    }
    
    
}
