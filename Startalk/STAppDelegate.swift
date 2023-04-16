//
//  STAppDelegate.swift
//  Startalk
//
//  Created by lei on 2023/1/11.
//

import UIKit
import CoreData

@main
class STAppDelegate: UIResponder, UIApplicationDelegate {

    var window:UIWindow?
    
    var appStateManager = STKit.shared.appStateManager
    var notificationManager = STKit.shared.notificationManager

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        appStateManager.initialize()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        notificationManager.receiveToken(deviceToken)
    }
    
}

