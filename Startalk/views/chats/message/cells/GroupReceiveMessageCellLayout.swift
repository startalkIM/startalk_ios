//
//  GroupReceiveMessageCellLayout.swift
//  Startalk
//
//  Created by lei on 2023/5/16.
//

import UIKit

class GroupReceiveMessageCellLayout: MessgeCellLayout{
    
    func layout(photoImageView: UIView, nameLabel: UIView, contentsView: UIView, contentView: UIView, stateView: MessageStateView) {
        
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            photoImageView.widthAnchor.constraint(equalToConstant: 46),
            photoImageView.heightAnchor.constraint(equalToConstant: 46),
        ])
        photoImageView.layer.cornerRadius = 23
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
        ])
        
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentsView.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 10),
            contentsView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            contentsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        stateView.isHidden = true
    }
    
    
}
