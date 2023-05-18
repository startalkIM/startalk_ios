//
//  STMessageInputFunctionsView.swift
//  Startalk
//
//  Created by lei on 2023/4/3.
//

import UIKit

class STMessageInputFunctionsView: UIView {
    
    var imageFunctionView: InputFunctionView!
    
    weak var delegate: InputFunctionViewDelegate?{
        didSet{
            imageFunctionView.delegate = delegate
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
        imageFunctionView = InputFunctionView()
        imageFunctionView.setLabel("Images")
        addSubview(imageFunctionView)
        
    }
    
    func layoutElements(){
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7).isActive = true
        
        imageFunctionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageFunctionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            imageFunctionView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            imageFunctionView.widthAnchor.constraint(equalToConstant: 70),
            imageFunctionView.heightAnchor.constraint(equalToConstant: 90),
        ])
    }
}
