//
//  LoginView.swift
//  Startalk
//
//  Created by lei on 2023/2/20.
//

import UIKit

class STLoginView: UIView {
    var titleLabel: UILabel!
    var scanButton: UIButton!
    var usernameTextFieled: UITextField!
    var usernameTextLine: UIView!
    var passwordTextField: UITextField!
    var passwordTextLine: UIView!
    var privacyPolicyView: UIView!
    var forgetPasswordButton: UIButton!
    var loginButton: UIButton!
    var navigationSwitcher: UIView!
    
    var delegate: STLoginViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addTitleLabel()
        addScanButton()
        addUsernameTextField()
        addPasswordTextField()
        
        
        layoutTitleLabel()
        layoutScanButton()
        layoutUsernameTextField()
        layoutPasswordTextField()
    }
    
    func addTitleLabel(){
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 26)
        label.textColor = UIColor.make(0x333333)
        label.text = "Login"
        label.sizeToFit()
        
        addSubview(label)
        self.titleLabel = label
    }
    
    func layoutTitleLabel(){
        let label = titleLabel!
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 33),
            label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 56),
            label.widthAnchor.constraint(equalToConstant: 150),
            label.heightAnchor.constraint(equalToConstant: 38),
        ])
    }
    
    func addScanButton(){
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.make(0x00CABE)
        button.setTitle("Scan", for: .normal)
        button.setTitleColor(UIColor.make(0xFFFFFF), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: UIFont.Weight(4))
        button.setImage(UIImage(named: ""), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -3.5, bottom: 0, right: 3.5)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3.5, bottom: 0, right: -3.5)
        
        addSubview(button)
        button.addTarget(delegate, action: #selector(delegate.scanButtonClicked), for: .touchUpInside)
        self.scanButton = button
    }
    
    func layoutScanButton(){
        let button = scanButton!
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -24),
            button.heightAnchor.constraint(equalToConstant: 30),
            button.widthAnchor.constraint(equalToConstant: 126)
        ])
    }
    
    func addUsernameTextField(){
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.backgroundColor = .white
        
        addSubview(textField)
        textField.delegate = delegate
        self.usernameTextFieled = textField
        
        let line = UIView()
        line.backgroundColor = UIColor.make(0xDDDDDD)
        
        addSubview(line)
        self.usernameTextLine = line
    }
    
    func layoutUsernameTextField(){
        let textField = self.usernameTextFieled!
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 33),
            textField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -33),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 84),
            textField.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        let line = self.usernameTextLine!
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            line.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 5),
            line.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
    func addPasswordTextField(){
        let textfield = UITextField()
        textfield.placeholder = "Password"
        textfield.keyboardType = .asciiCapable
        textfield.isSecureTextEntry = true
        textfield.autocorrectionType = .no
        textfield.clearButtonMode = .whileEditing
        textfield.backgroundColor = .white
        textfield.returnKeyType = .go
        
        textfield.delegate = delegate
        addSubview(textfield)
        self.passwordTextField = textfield
        
        let line = UIView()
        line.backgroundColor = UIColor.make(0xDDDDDD)
        
        addSubview(line)
        self.passwordTextLine = line
    }
    
    func layoutPasswordTextField(){
        let textField = self.passwordTextField!
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 33),
            textField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -33),
            textField.topAnchor.constraint(equalTo: usernameTextLine.bottomAnchor, constant: 30),
            textField.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        let line = self.passwordTextLine!
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            line.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 5),
            line.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
    func addPrivacyPolicyView(){
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc
protocol STLoginViewDelegate: UITextFieldDelegate{
    func scanButtonClicked()
}
