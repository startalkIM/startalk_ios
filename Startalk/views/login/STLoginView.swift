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
    var policyButton: UIButton!
    var policyLabel: UILabel!
    var forgetPasswordButton: UIButton!
    var loginButton: UIButton!
    var corporationLabel: UILabel!
    var navigationSwitcher: UIButton!
    
    var delegate: STLoginViewDelegate? {
        didSet{
            delegateDidSet(delegate)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        addTitleLabel()
        addScanButton()
        addUsernameTextField()
        addPasswordTextField()
        addPolicyButton()
        addPolicyLabel()
        addForgetPasswordButton()
        addLoginButton()
        addCorporationLabel()
        addNavigationSwitcher()
        
        layoutTitleLabel()
        layoutScanButton()
        layoutUsernameTextField()
        layoutPasswordTextField()
        layoutPolicyButton()
        layoutPolicyLabel()
        layoutForgetPasswordButton()
        layoutLoginButton()
        layoutCorporationAndSwitcher()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTitleLabel(){
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 26)
        label.textColor = UIColor.make(0x333333)
        label.text = "login".localized
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
        let button = ComponentFactory.makeScanButton()
        
        addSubview(button)
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
        textField.placeholder = "login_username".localized
        textField.backgroundColor = .systemBackground
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .next
        
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
        textfield.placeholder = "login_password".localized
        textfield.keyboardType = .asciiCapable
        textfield.isSecureTextEntry = true
        textfield.autocorrectionType = .no
        textfield.clearButtonMode = .whileEditing
        textfield.backgroundColor = .systemBackground
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
    
    func addPolicyButton(){
        let button = UIButton()
        let image = UIImage(named: "login/check")
        button.setImage(image?.withTintColor(.make(0xE4E4E4)), for: .normal)
        button.setImage(image?.withTintColor(.make(0x00CABE)), for: .selected)
        
        addSubview(button)
        self.policyButton = button
    }
    
    func layoutPolicyButton(){
        let button = policyButton!
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: passwordTextLine.leadingAnchor),
            button.topAnchor.constraint(equalTo: passwordTextLine.bottomAnchor, constant: 31),
            button.widthAnchor.constraint(equalToConstant: 17),
            button.heightAnchor.constraint(equalToConstant: 17),
        ])
    }
    
    func addPolicyLabel(){
        let label = UILabel()
        label.textColor = .make(0x999999)
        label.font = .systemFont(ofSize: 14)
        let agreeText = "login_agree".localized
        let policyText = "login_privacy_policy".localized
        let text = "\(agreeText)\(policyText)"
        let policyRange = NSString(string: text).range(of: policyText)
        let attributedTitle = NSMutableAttributedString(string: text)
        attributedTitle.setAttributes([.foregroundColor: UIColor.spectralGrayBlue], range: policyRange)
        label.attributedText = attributedTitle
        
        label.isUserInteractionEnabled = true
        addSubview(label)
        self.policyLabel = label
    }
    
    func layoutPolicyLabel(){
        let label = policyLabel!
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: policyButton.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: policyButton.centerYAnchor),
        ])
    }
    
    func addForgetPasswordButton(){
        let button = UIButton()
        button.setTitle("login_forget_password".localized, for: .normal)
        button.setTitleColor(.make(0x00CABE), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        
        addSubview(button)
        self.forgetPasswordButton = button
    }
    
    func layoutForgetPasswordButton(){
        let button = forgetPasswordButton!
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: policyButton.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: passwordTextLine.trailingAnchor),
        ])
    }
    
    
    func addLoginButton(){
        let button = UIButton()
        button.setTitle("login".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .make(0x00CABE)
        button.layer.cornerRadius = 24.0
        button.layer.masksToBounds = true
        button.setBackgroundImage(UIColor.make(0xABE9E5).image(), for: .disabled)
        button.setBackgroundImage(UIColor.make(0x00CABE).image(), for: .normal)
        
        addSubview(button)
        self.loginButton = button
    }
    
    func layoutLoginButton(){
        let button = loginButton!
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 40),
            button.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -40),
            button.topAnchor.constraint(equalTo: policyButton.bottomAnchor, constant: 56),
            button.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    func addCorporationLabel(){
        let label = UILabel()
        label.textColor = .make(0x999999)
        label.font = .systemFont(ofSize: 15)
        
        addSubview(label)
        self.corporationLabel = label
    }
    
    
    func addNavigationSwitcher(){
        let button = UIButton()
        let image = UIImage(named: "login/switch")?.withTintColor(.make(0x00CABE))
        button.setImage(image, for: .normal)
        
        addSubview(button)
        self.navigationSwitcher = button
    }
    
    func layoutCorporationAndSwitcher(){
        let layout = UILayoutGuide()
        addLayoutGuide(layout)
        let label = corporationLabel!
        let button = navigationSwitcher!
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            layout.centerXAnchor.constraint(equalTo: centerXAnchor),
            layout.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30),
            
            label.leadingAnchor.constraint(equalTo: layout.leadingAnchor),
            label.topAnchor.constraint(equalTo: layout.topAnchor),
            label.bottomAnchor.constraint(equalTo: layout.bottomAnchor),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 220),
            
            button.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5),
            button.trailingAnchor.constraint(equalTo: layout.trailingAnchor),
            button.widthAnchor.constraint(equalToConstant: 22),
            button.heightAnchor.constraint(equalToConstant: 22),
            button.centerYAnchor.constraint(equalTo: layout.centerYAnchor),
        ])
    }
    
    
    func delegateDidSet(_ delegate: STLoginViewDelegate?){
        usernameTextFieled.delegate = delegate
        passwordTextField.delegate = delegate
        
        if let delegate = delegate{
            scanButton.addTarget(delegate, action: #selector(delegate.scanButtonTapped), for: .touchUpInside)
            usernameTextFieled.addTarget(delegate, action: #selector(delegate.usernameChanged), for: .editingChanged)
            passwordTextField.addTarget(delegate, action: #selector(delegate.passwordChanged), for: .editingChanged)
            policyButton.addTarget(delegate, action: #selector(delegate.policyButtonTapped), for: .touchUpInside)
            let tapGesture = UITapGestureRecognizer(target: delegate, action: #selector(delegate.policyLabelTapped))
            policyLabel.addGestureRecognizer(tapGesture)
            loginButton.addTarget(delegate, action: #selector(delegate.loginButtonTapped), for: .touchUpInside)
            forgetPasswordButton.addTarget(delegate, action: #selector(delegate.forgetPasswordButtonTapped), for: .touchUpInside)
            navigationSwitcher.addTarget(delegate, action: #selector(delegate.navigationSwitcherTapped), for: .touchUpInside)

        }else{
            scanButton.removeTarget(nil, action: nil, for: .touchUpInside)
            usernameTextFieled.removeTarget(nil, action: nil, for: .editingChanged)
            passwordTextField.removeTarget(nil, action: nil, for: .editingChanged)
            policyButton.removeTarget(nil, action: nil, for: .touchUpInside)
            policyLabel.gestureRecognizers = nil
            loginButton.removeTarget(nil, action: nil, for: .touchUpInside)
            forgetPasswordButton.removeTarget(nil, action: nil, for: .touchUpInside)
            navigationSwitcher.removeTarget(nil, action: nil, for: .touchUpInside)
        }
    }
    
}

extension STLoginView{
    
    func setNavigationName(_ value: String){
        corporationLabel.text = value
    }
}

@objc
protocol STLoginViewDelegate: UITextFieldDelegate{
    func scanButtonTapped()
    
    func usernameChanged()
    
    func passwordChanged()
    
    func policyButtonTapped()
    
    func policyLabelTapped()
    
    func forgetPasswordButtonTapped()
    
    func loginButtonTapped()
    
    func navigationSwitcherTapped()
    
   
}
