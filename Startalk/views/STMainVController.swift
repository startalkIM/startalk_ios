//
//  STMainVController.swift
//  Startalk
//
//  Created by lei on 2023/1/11.
//

import UIKit
import Combine

class STMainVController: STSwitchController{
    
    let appStateManager = STKit.shared.appStateManager
    let notificationCenter = STKit.shared.notificationCenter
    
    override func viewDidLoad() {
        let state = appStateManager.state
        setController(state: state)

        notificationCenter.observeAppStateChanged(self, handler: stateChanged(_:))
    }
    
    func stateChanged(_ state: STAppState){
        DispatchQueue.main.async { [self] in
            setController(state: state)
        }
    }
    
    func setController(state: STAppState){
        let controller: UIViewController
        if state == .login{
            controller = STLoginVController()
        }else{
            let tabController = STContentVController()
            controller = UINavigationController(rootViewController: tabController)
        }
        show(controller)
    }
}
