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
    let loginManager: STLoginManager
    let navigationManager: STNavigationManager
    
    private init(){
        identifiers = STIdentifiers()
        navigationManager = STNavigationManager()
        loginManager = STLoginManager(identifiers: identifiers, navigationManager: navigationManager)
    }
    
    
}
