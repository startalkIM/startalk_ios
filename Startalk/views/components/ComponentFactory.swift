//
//  ComponentFactory.swift
//  Startalk
//
//  Created by lei on 2023/2/25.
//

import UIKit

class ComponentFactory{
    
    static func makeScanButton() -> UIButton{
        let button = UIButton()
        button.backgroundColor = UIColor.make(0x00CABE)
        button.setTitle("scan".localized, for: .normal)
        button.setTitleColor(UIColor.make(0xFFFFFF), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: UIFont.Weight(4))
        let image = UIImage(named: "login/scan")?.withTintColor(.white)
        button.setImage(image, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -3.5, bottom: 0, right: 3.5)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3.5, bottom: 0, right: -3.5)
        
        return button
    }
}
