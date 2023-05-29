//
//  MessageStateView.swift
//  Startalk
//
//  Created by lei on 2023/5/27.
//

import UIKit

class MessageStateView: UIView {
    
    var sendingIndicator: UIActivityIndicatorView!
    var failedView: UIButton!
    var messageId: String!
    
    weak var delegate: MessageStateViewDelegate?
    
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
        
        failedView = UIButton(type: .system)
        let image = UIImage(named: "chat/failed")
        failedView.setImage(image, for: .normal)
        failedView.tintColor = .systemRed
        failedView.addTarget(self, action: #selector(resend), for: .touchUpInside)
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
    
    func setMessage(_ message: STMessage){
        messageId = message.id
        let state = message.state
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
    
    @objc
    func resend(){
        delegate?.resend(id: messageId)
    }
}

@objc
protocol MessageStateViewDelegate: AnyObject{
    func resend(id: String)
}
