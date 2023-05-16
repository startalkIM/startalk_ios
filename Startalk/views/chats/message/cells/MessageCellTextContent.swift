//
//  MessageCellTextContent.swift
//  Startalk
//
//  Created by lei on 2023/5/16.
//

import UIKit
import XMPPClient

class MessageCellTextContent: UIView {
    
    var contentLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize(){
        clipsToBounds = true
        layer.cornerRadius = 5
        
        contentLabel = UILabel()
        contentLabel.font = .systemFont(ofSize: 15)
        contentLabel.textColor = .black
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.numberOfLines = 0
        addSubview(contentLabel)
        
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            contentLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200)
        ])
    }
    
    func setContent(_ content: XCTextMessageContent){
        contentLabel.text = content.value
    }
}
