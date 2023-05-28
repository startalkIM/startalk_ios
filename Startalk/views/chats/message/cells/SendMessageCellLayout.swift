//
//  SendMessageCellLayout.swift
//  Startalk
//
//  Created by lei on 2023/5/16.
//

import UIKit

class SendMessageCellLayout: MessgeCellLayout{
    
    func layout(photoImageView: UIView, nameLabel: UIView, contentsView: UIView, contentView: UIView, stateView: MessageStateView) {
        
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            photoImageView.widthAnchor.constraint(equalToConstant: 46),
            photoImageView.heightAnchor.constraint(equalToConstant: 46),
        ])
        photoImageView.layer.cornerRadius = 23
        
        nameLabel.isHidden = true
        
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentsView.trailingAnchor.constraint(equalTo: photoImageView.leadingAnchor, constant: -10),
            contentsView.topAnchor.constraint(equalTo: photoImageView.topAnchor),
            contentsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        stateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stateView.trailingAnchor.constraint(equalTo: contentsView.leadingAnchor, constant: -10),
            stateView.centerYAnchor.constraint(equalTo: contentsView.centerYAnchor),
            stateView.widthAnchor.constraint(equalToConstant: 15),
            stateView.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    
}
