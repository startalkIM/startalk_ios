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
    var policyButton: UIButton!
    var loginButton: UIButton!
    
    override func loadView() {
        let loginView = STLoginView()
        usernameTextField = loginView.usernameTextFieled
        passwordTextField = loginView.passwordTextField
        policyButton = loginView.policyButton
        loginButton = loginView.loginButton
        
        loginView.delegate = self
        view = loginView
        
        checkLoginButton()
        loginView.setCorporation("cn")
    }
    
    func checkLoginButton(){
        let usernameValid = !(usernameTextField.text ?? "").isEmpty
        let passwrodValid = !(passwordTextField.text ?? "").isEmpty
        if policyButton.isSelected && usernameValid && passwrodValid{
            loginButton.isEnabled = true
        }else{
            loginButton.isEnabled = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}


extension STLoginVController{
    func scanButtonTapped() {
        
    }
    
    func usernameChanged() {
        checkLoginButton()
    }
    
    func passwordChanged() {
        checkLoginButton()
    }
    
    func policyButtonTapped() {
        policyButton.isSelected.toggle()
        checkLoginButton()
    }
    
    func policyLabelTapped() {
        
    }
    
    
    func forgetPasswordButtonTapped() {
        
    }
    
    func loginButtonTapped() {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        showLoadingView()
        loginManager.login(username: username, password: password) { success, message in
            DispatchQueue.main.async {
                self.hideLoadingView()
            }
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
