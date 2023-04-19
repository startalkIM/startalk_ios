//
//  STSendMessageTableCell.swift
//  Startalk
//
//  Created by lei on 2023/3/27.
//

import UIKit

class STSendMessageTableCell: UITableViewCell {
    static let IDENTIFIER = "send_message_cell"
    static let ESTIMATED_HEIGHT: CGFloat = 80
    
    static let singlePhoto = UIImage(named: "chat/single_photo")
    
    var profileImageView: UIImageView!
    var contentLabel: UILabel!
    var bubbleView: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        addElements()
        layoutElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addElements(){
        profileImageView = UIImageView()
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        contentView.addSubview(profileImageView)
        
        bubbleView = UIView()
        bubbleView.backgroundColor = .make(0xC5EAEE)
        bubbleView.clipsToBounds = true
        contentView.addSubview(bubbleView)
        
        contentLabel = UILabel()
        contentLabel.font = .systemFont(ofSize: 15)
        contentLabel.textColor = .black
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.numberOfLines = 0
        contentView.addSubview(contentLabel)
        
    }
    
    func layoutElements(){
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            profileImageView.widthAnchor.constraint(equalToConstant: 46),
            profileImageView.heightAnchor.constraint(equalToConstant: 46),
        ])
        profileImageView.layer.cornerRadius = 23
        
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bubbleView.trailingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: -10),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        bubbleView.layer.cornerRadius = 5
        
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
            contentLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
            contentLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            contentLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
            contentLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
        ])
    }

    func setMessage(_ message: STMessage, user: User?){
        profileImageView.setSource(user?.photo, placeholder: Self.singlePhoto)
        contentLabel.text = message.content.value
    }

}
