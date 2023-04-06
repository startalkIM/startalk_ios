//
//  STMainVController.swift
//  Startalk
//
//  Created by lei on 2023/1/11.
//

import UIKit
import Combine

class STMainVController: STSwitchController{
    
    let loginController: STLoginVController
    
    let contentController: UINavigationController
    
    let appStateManager = STKit.shared.appStateManager
    let notificationCenter = STKit.shared.notificationCenter
    
    required init?(coder: NSCoder) {
        loginController = STLoginVController()
    
        let tabController = STContentVController()
        contentController = UINavigationController(rootViewController: tabController)
        
        super.init(coder: coder)
        
    }
    
    override func viewDidLoad() {
        if appStateManager.state == .login{
            show(loginController)
        }else{
            show(contentController)
        }

        notificationCenter.observeAppStateChanged(self, handler: stateChanged(_:))
    }
    
    func stateChanged(_ state: STAppState){
        DispatchQueue.main.async { [self] in
            if state == .login{
                show(loginController)
            }else{
                show(contentController)
            }
        }
    }
}
