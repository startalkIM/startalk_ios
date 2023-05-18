//
//  InputFunctionView.swift
//  Startalk
//
//  Created by lei on 2023/5/18.
//

import UIKit

class InputFunctionView: UIView{
    
    var icon: UIView!
    var label: UILabel!
    
    weak var delegate: InputFunctionViewDelegate?{
        didSet{
            delegateDidSet(delegate)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addElements()
        layoutElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addElements(){
        icon = UIView()
        icon.backgroundColor = .systemGray5
        icon.clipsToBounds = true
        addSubview(icon)
        
        label = UILabel()
        label.font = .systemFont(ofSize: 14)
        addSubview(label)
        
    }
    
    func layoutElements() {
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            icon.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            icon.widthAnchor.constraint(equalToConstant: 50),
            icon.heightAnchor.constraint(equalToConstant: 50),
        ])
        icon.layer.cornerRadius = 5
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
    
    func delegateDidSet(_ delegate: InputFunctionViewDelegate?){
        if let delegate = delegate{
            let tapGesture = UITapGestureRecognizer(target: delegate, action: #selector(delegate.sendImage))
            addGestureRecognizer(tapGesture)
        }else{
            gestureRecognizers = nil
        }
    }
    
    func setLabel(_ text: String){
        label.text = text
    }
}

@objc
protocol InputFunctionViewDelegate: AnyObject{
    
    func sendImage()
}
