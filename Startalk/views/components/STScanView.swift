//
//  STScanView.swift
//  Startalk
//
//  Created by lei on 2023/3/3.
//

import UIKit

class STScanView: STBaseScanView {
    var cancelButton: UIButton!
    var titleLabel: UILabel!
    
    var imageBackgound: UIView!
    var imageButton: UIButton!
    var imageLabel: UILabel!
    
    var lightButton: UIButton!
    var lightLabel: UILabel!
    
    var delegate: STScanViewDelegate?{
        didSet{
            delegateDidSet(delegate)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addCancelButton()
        addTitleLabel()
        addImageButton()
        addLightButton()
        
        layoutCancelButton()
        layoutTitleLabel()
        layoutImageButton()
        layoutLightButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addCancelButton(){
        let button = UIButton(type: .system)
        button.setTitle("cancel".localized, for: .normal)
        button.tintColor = .white
        
        addSubview(button)
        self.cancelButton = button
    }
    
    func addTitleLabel(){
        let label = UILabel()
        label.text = "scan".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 19, weight: .bold)
        
        addSubview(label)
        self.titleLabel = label
    }
    
    func addImageButton(){
        let effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let background = UIVisualEffectView(effect: effect)
        background.clipsToBounds = true
        addSubview(background)
        self.imageBackgound = background
        
        let button = UIButton()
        let configuartion = UIImage.SymbolConfiguration(pointSize: 24, weight: .thin)
        let image = UIImage(systemName: "photo", withConfiguration: configuartion)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        addSubview(button)
        self.imageButton = button
        
        let label = UILabel()
        label.text = "alblum".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        addSubview(label)
        self.imageLabel = label
    }
    
    func addLightButton(){
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let offImage = UIImage(systemName: "flashlight.off.fill", withConfiguration: configuration)
        button.setImage(offImage, for: .normal)
        
        let onImage = UIImage(systemName: "flashlight.on.fill", withConfiguration: configuration)
        button.setImage(onImage, for: .selected)
        button.tintColor = .white
        
        button.addTarget(self, action: #selector(lightButtonTapped), for: .touchUpInside)
        addSubview(button)
        self.lightButton = button
        
        let label = UILabel()
        label.text = "scan_turn_light_on".localized
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white
        addSubview(label)
        self.lightLabel = label
    }
    
    func layoutCancelButton(){
        let button = cancelButton!
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 10),
            button.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 20),
        ])
    }
    
    func layoutTitleLabel(){
        let label = titleLabel!
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor)
        ])
    }
    
    func layoutImageButton(){
        let layout = UILayoutGuide()
        addLayoutGuide(layout)
        NSLayoutConstraint.activate([
            layout.leadingAnchor.constraint(equalTo: leadingAnchor),
            layout.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -40),
            layout.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 3),
        ])
        
        let background = imageBackgound!
        background.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            background.centerXAnchor.constraint(equalTo: layout.centerXAnchor),
            background.topAnchor.constraint(equalTo: layout.topAnchor),
            background.widthAnchor.constraint(equalToConstant: 50),
            background.heightAnchor.constraint(equalToConstant: 50),
        ])
        background.layer.cornerRadius = 25
        
        let button = imageButton!
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 30),
            button.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        let label = imageLabel!
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: layout.centerXAnchor),
            label.topAnchor.constraint(equalTo: background.bottomAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: layout.bottomAnchor),
        ])
    }
    
    func layoutLightButton(){
        let button = lightButton!
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        let label = lightLabel!
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -40),
        ])
    }
    
    func delegateDidSet(_ delegate: STScanViewDelegate?){
        if let delegate = delegate{
            cancelButton.addTarget(delegate, action: #selector(delegate.cancelButtonTapped), for: .touchUpInside)
            imageButton.addTarget(delegate, action: #selector(delegate.imageButtonTapped), for: .touchUpInside)
        }else{
            cancelButton.removeTarget(nil, action: nil, for: .touchUpInside)
            imageButton.removeTarget(nil, action: nil, for: .touchUpInside)
        }
    }
    
    @objc
    func lightButtonTapped(){
        lightButton.isSelected.toggle()
        if lightButton.isSelected{
            lightButton.tintColor = nil
            lightLabel.text = "scan_turn_light_off".localized
            delegate?.turnLightOn()
        }else{
            lightButton.tintColor = .white
            lightLabel.text = "scan_turn_light_on".localized
            delegate?.turnLightOff()
        }
    }
    
    func showLightButton(){
        UIView.animate(withDuration: 0.2) { [self] in
            lightButton.alpha = 1
            lightLabel.alpha = 1
        }
    }
    
    func hideLightButton(){
        UIView.animate(withDuration: 0.2) { [self] in
            lightButton.alpha = 0
            lightLabel.alpha = 0
        }
    }

}

@objc
protocol STScanViewDelegate{
    
    func cancelButtonTapped()
    
    func imageButtonTapped()
    
    func turnLightOn()
    
    func turnLightOff()
}
