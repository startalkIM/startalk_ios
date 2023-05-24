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
    
    var loginVController: STLoginVController?
    var contentController: UINavigationController?
    
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
        if state == .login{
            if loginVController == nil{
                let controller = STLoginVController()
                show(controller)
                loginVController = controller
                contentController = nil
            }
        }else{
            if contentController == nil{
                let tabController = STContentVController()
                let controller = UINavigationController(rootViewController: tabController)
                show(controller)
                contentController = controller
                loginVController = nil
            }
        }
    }
}
