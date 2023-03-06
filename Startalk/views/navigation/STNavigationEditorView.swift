//
//  STNavigationEditorView.swift
//  Startalk
//
//  Created by lei on 2023/2/25.
//

import UIKit

class STNavigationEditorView: UIView {
    var scanButton: UIButton!
    var descriptionLabel: UILabel!
    var nameLabel: UILabel!
    var nameTextField: UITextField!
    var locationLabel: UILabel!
    var locationTextField: UITextField!
    
    var delegate: STNavigationEditorViewDelegate?{
        didSet{
            delegateDidSet(delegate)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addScanButton()
        addDescriptionLabel()
        addNameLabel()
        addNameTextField()
        addLocationLabel()
        addLocationTextField()
        
        layoutScanButton()
        layoutDescriptionLabel()
        layoutNameLabel()
        layoutNameTextField()
        layoutLocationLabel()
        layoutLocationTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addScanButton(){
        scanButton = ComponentFactory.makeScanButton()
        addSubview(scanButton)
    }
    
    func addDescriptionLabel(){
        let label = UILabel()
        label.text = "navigation_configure_manually".localized
        label.font = .systemFont(ofSize: 14)
        label.textColor = .make(0xBFBFBF)
        
        addSubview(label)
        descriptionLabel = label
    }
    
    func addNameLabel(){
        let label = UILabel()
        label.text = "navigation_name".localized
        label.font = .systemFont(ofSize: 16)
        addSubview(label)
        self.nameLabel = label
    }
    
    func addNameTextField(){
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 14)
        textField.placeholder = "navigation_input_name".localized
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.make(0xDDDDDD).cgColor
        addSubview(textField)
        self.nameTextField = textField
    }
    
    func addLocationLabel(){
        let label = UILabel()
        label.text = "navigation_location".localized
        label.font = .systemFont(ofSize: 16)
        addSubview(label)
        self.locationLabel = label
    }
    
    func addLocationTextField(){
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 14)
        textField.placeholder = "navigation_input_location".localized
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.make(0xDDDDDD).cgColor
        addSubview(textField)
        self.locationTextField = textField
    }
    
    func layoutScanButton(){
        let button = scanButton!
        let layoutGuide = safeAreaLayoutGuide
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
            button.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 26),
            button.widthAnchor.constraint(equalToConstant: 175),
            button.heightAnchor.constraint(equalToConstant: 40),
        ])

    }
    
    func layoutDescriptionLabel(){
        let label = descriptionLabel!
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            label.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 36),
            label.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func layoutNameLabel(){
        let label = nameLabel!
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            label.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            label.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    func layoutNameTextField(){
        let textField = nameTextField!
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant:  -20),
            textField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            textField.heightAnchor.constraint(equalToConstant: 36),
        ])
    }
    
    func layoutLocationLabel(){
        let label = locationLabel!
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: locationTextField.leadingAnchor),
            label.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30),
            label.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    func layoutLocationTextField(){
        let textField = locationTextField!
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant:  -20),
            textField.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 10),
            textField.heightAnchor.constraint(equalToConstant: 36),
        ])
    }
    
    func delegateDidSet(_ delegate: STNavigationEditorViewDelegate?){
        if let delegate = delegate{
            scanButton.addTarget(delegate, action: #selector(delegate.scanButtonTapped), for: .touchUpInside)
            nameTextField.addTarget(delegate, action: #selector(delegate.nameChanged), for: .editingChanged)
            locationTextField.addTarget(delegate, action: #selector(delegate.locationChanged), for: .editingChanged)
        }else{
            scanButton.removeTarget(nil, action: nil, for: .touchUpInside)
            nameTextField.removeTarget(nil, action: nil, for: .editingChanged)
            locationTextField.removeTarget(nil, action: nil, for: .editingChanged)
        }
    }
}

extension STNavigationEditorView{
    func setItem(_ item: STNavigationLocation){
        nameTextField.text = item.name
        locationTextField.text = item.location
    }
}

@objc
protocol STNavigationEditorViewDelegate: UITextFieldDelegate{
    
    func scanButtonTapped()
    
    func nameChanged()
    
    func locationChanged()
}
