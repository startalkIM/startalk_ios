//
//  STNavigationQrCodeView.swift
//  Startalk
//
//  Created by lei on 2023/3/6.
//

import UIKit

class STNavigationQrCodeView: UIView {
    var containerView: UIView!
    var nameLabel: UILabel!
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        
        addContainerView()
        addNameLabel()
        addImageView()
        
        layoutContainerView()
        layoutNameLabel()
        layoutImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addContainerView(){
        containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        addSubview(containerView)
    }
    
    func addNameLabel(){
        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        addSubview(nameLabel)
    }

    func addImageView(){
        imageView = UIImageView()
        addSubview(imageView)
    }
    
    func layoutContainerView(){
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
        ])
    }
    
    func layoutNameLabel(){
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20 + 10),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
        ])
    }
    
    func layoutImageView(){
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            imageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
        ])
    }
}
