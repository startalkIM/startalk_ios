//
//  PrivateReceiveMessageCellLayout.swift
//  Startalk
//
//  Created by lei on 2023/5/16.
//

import UIKit

class PrivateReceiveMessageCellLayout: MessgeCellLayout{
    
    func layout(photoImageView: UIView, nameLabel: UIView, contentsView: UIView, contentView: UIView) {
        
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            photoImageView.widthAnchor.constraint(equalToConstant: 46),
            photoImageView.heightAnchor.constraint(equalToConstant: 46),
        ])
        photoImageView.layer.cornerRadius = 23
        
        nameLabel.isHidden = true
        
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentsView.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 10),
            contentsView.topAnchor.constraint(equalTo: photoImageView.topAnchor),
            contentsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    
}
