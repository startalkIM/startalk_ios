//
//  STLoginVController.swift
//  Startalk
//
//  Created by lei on 2023/2/20.
//

import UIKit

class STLoginVController: STEditableViewController, STLoginViewDelegate{
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
        let usernameValid = StringUtil.isNotEmpty(usernameTextField.text)
        let passwrodValid = StringUtil.isNotEmpty(passwordTextField.text)
        
        loginButton.isEnabled = usernameValid && passwrodValid
    }
    
    func login(){
        guard policyButton.isSelected else{
            showAlert(title: "reminder".localized, message: "login_argree_first".localized)
            return
        }
        
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty
        else{
            return
        }
        
        showLoadingView("login_waiting".localized)
                
        loginManager.login(username: username, password: password) { success, message in
            DispatchQueue.main.async {
                self.hideLoadingView{
                    if !success{
                        self.showAlert(message: "login_unauthenticated".localized)
                    }
                }

            }
            
        }
    }

}

extension STLoginVController: UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    func scanButtonTapped() {
        let scanViewController = STScanVController()
        scanViewController.modalPresentationStyle = .fullScreen
        
        scanViewController.completion = { text in
            self.dismiss(animated: true){
                let editorController = STNavigationEditorVController()
                editorController.location.location = text
                editorController.modalPresentationStyle = .fullScreen
                self.presentInNavigationController(editorController, animated: true)
            }
        }
        present(scanViewController, animated: true)
    }
    
    func usernameChanged() {
        checkLoginButton()
    }
    
    func passwordChanged() {
        checkLoginButton()
    }
    
    func policyButtonTapped() {
        policyButton.isSelected.toggle()
    }
    
    func policyLabelTapped() {
        
    }
    
    
    func forgetPasswordButtonTapped() {
        
    }
    
    func loginButtonTapped() {
      login()
    }
    
    func navigationSwitcherTapped() {
        
        let viewController = STNavigationListVController()
        viewController.modalPresentationStyle = .fullScreen
        presentInNavigationController(viewController, animated: true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField{
            usernameTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        }else if textField == passwordTextField{
            passwordTextField.resignFirstResponder()
            login()
        }
        
        return true
    }

}
