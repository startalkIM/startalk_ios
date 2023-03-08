//
//  STBadgeView.swift
//  Startalk
//
//  Created by lei on 2023/3/8.
//

import UIKit

class STBadgeView: UIView {
    var count = 1{
        didSet{
            text = Self.makeText(count)
            label.text = text
            invalidateIntrinsicContentSize()
        }
    }
    
    var text: String
    
    var label: UILabel
    
    override init(frame: CGRect) {
        label = UILabel()
        text = Self.makeText(count)
        super.init(frame: frame)
        
        backgroundColor = .make(0xEB524A)
        layer.cornerRadius = 9
        clipsToBounds = true
        
       
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize{
        let height: CGFloat = 18
        var width =  label.intrinsicContentSize.width + 8
        if width < height{
            width = height
        }
        return CGSize(width: width, height: height)
    }
    
    static func makeText(_ count: Int) -> String{
        let text: String
        if count <= 99{
            text = String(count)
        }else{
            text = "99+"
        }
        return text
    }
}
