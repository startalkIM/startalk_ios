//
//  STStickersView.swift
//  Startalk
//
//  Created by lei on 2023/4/3.
//

import UIKit

class STMessageStickersView: UIView {

    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .brown
        addElements()
        layoutElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addElements(){
        label = UILabel()
        label.text = "Stickers"
        addSubview(label)
        
    }
    
    func layoutElements(){
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7).isActive = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
