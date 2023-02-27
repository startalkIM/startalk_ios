//
//  STLoginVController.swift
//  Startalk
//
//  Created by lei on 2023/2/20.
//

import UIKit

class STLoginVController: UIViewController, STLoginViewDelegate{
    let loginManager = STKit.shared.loginManager
    
    
    var usernameTextField: UITextField!
    var passwordTextField: UITextField!
    
    override func loadView() {
        let loginView = STLoginView()
        usernameTextField = loginView.usernameTextFieled
        passwordTextField = loginView.passwordTextField
        
        loginView.delegate = self
        
        view = loginView
        
        //loginView.policyButton.isSelected = true
        loginView.loginButton.isEnabled = true
        loginView.setCorporation("cn")
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
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        loginManager.login(username: username, password: password) { success, message in
            if success{
                print("login succcess")
            }else{
                print("login failed", message)
            }
        }
    }
    
    func navigationSwitcherTapped() {
        
        let viewController = STNavigationListVController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
}
