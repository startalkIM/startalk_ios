//
//  STMainVController.swift
//  Startalk
//
//  Created by lei on 2023/1/11.
//

import UIKit
import Combine

class STMainVController: STSwitchController, STLoginDelegate{
    
    let loginController: STLoginVController
    
    let contentController: UINavigationController
    
    let appState  = STKit.shared.appState
    let loginManager = STKit.shared.loginManager
    
    required init?(coder: NSCoder) {
        loginController = STLoginVController()
    
        let tabController = STContentVController()
        contentController = UINavigationController(rootViewController: tabController)
        
        super.init(coder: coder)
        
    }
    
    override func viewDidLoad() {
        if appState.isLoggedIn{
            setViewController(contentController)
        }else{
            setViewController(loginController)
        }
        
        loginManager.delegate = self
    }
}


extension STMainVController{
    func didLogin() {
        DispatchQueue.main.async { [self] in
            setViewController(contentController)
        }
    }
    
    func didLogout() {
        DispatchQueue.main.async { [self] in
            setViewController(loginController)
        }
    }
}
