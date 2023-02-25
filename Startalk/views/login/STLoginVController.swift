//
//  STLoginVController.swift
//  Startalk
//
//  Created by lei on 2023/2/20.
//

import UIKit

class STLoginVController: UIViewController, STLoginViewDelegate{
    
    override func loadView() {
        let loginView = STLoginView()
        loginView.delegate = self
        
        view = loginView
        
        //loginView.policyButton.isSelected = true
        loginView.loginButton.isEnabled = true
        loginView.setCorporation("iStarTalk")
    }
    
    func scanButtonTapped() {
        
    }
    
    func policyButtonTapped() {
        
    }
    
    func policyLabelTapped() {
        
    }
    
    
    func forgetPasswordButtonTapped() {
        
    }
    
    func loginButtonTapped() {
        
    }
    
    func navigationSwitcherTapped() {
        
        let viewController = STNavigationListVController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
}
