//
//  MessageStateView.swift
//  Startalk
//
//  Created by lei on 2023/5/27.
//

import UIKit

class MessageStateView: UIView {
    
    var sendingIndicator: UIActivityIndicatorView!
    var failedView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addElements()
        layoutElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addElements(){
        sendingIndicator = UIActivityIndicatorView()
        addSubview(sendingIndicator)
        sendingIndicator.isHidden = true
        
        failedView = UIImageView()
        failedView.image = UIImage(named: "chat/failed")
        failedView.tintColor = .systemRed
        addSubview(failedView)
        failedView.isHidden = true
    }
    
    func layoutElements(){
        sendingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendingIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            sendingIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            sendingIndicator.topAnchor.constraint(equalTo: topAnchor),
            sendingIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        failedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            failedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            failedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            failedView.topAnchor.constraint(equalTo: topAnchor),
            failedView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func setState(_ state: STMessage.State){
        switch state{
        case .sending:
            sendingIndicator.isHidden = false
            sendingIndicator.startAnimating()
            failedView.isHidden = true
        case .failed:
            sendingIndicator.isHidden = true
            failedView.isHidden = false
        default:
            sendingIndicator.isHidden = true
            failedView.isHidden = true
        }
    }
}
