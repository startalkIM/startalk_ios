//
//  STChatCell.swift
//  Startalk
//
//  Created by lei on 2023/3/8.
//

import UIKit

class STChatTableCell: UITableViewCell {
    static let IDENTIFIER  = "chat_cell"
    static let CELL_HEIGHT: CGFloat = 72
    static let SEPARATOR_INSET: CGFloat = 72
        
    static let sendingImage = UIImage(named: "chat/sending")
    static let failedImage = UIImage(named: "chat/failed")
    static let singlePhoto = UIImage(named: "chat/single_photo")
    static let groupPhoto = UIImage(named: "chat/group_photo")
        
    var profileImageView: UIImageView!
    var titleLabel: UILabel!
    var timestampLabel: UILabel!
    
    var briefStack: UIStackView!
    var statusImageView: UIImageView!
    var unreadCountlabel: UILabel!
    var briefLabel: UILabel!
    
    var noteStack: UIStackView!
    var badgeView: STBadgeView!
    var mutedImageView: UIImageView!
    var unreadNoteView: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
        
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 17)
        contentView.addSubview(titleLabel)

        timestampLabel = UILabel()
        timestampLabel.font = .systemFont(ofSize: 12)
        timestampLabel.textColor = .make(0xBFBFBF)
        contentView.addSubview(timestampLabel)

        briefStack = UIStackView()
        briefStack.axis = .horizontal
        briefStack.alignment = .center
        briefStack.spacing = 2
        contentView.addSubview(briefStack)

        statusImageView = UIImageView()
        contentView.addSubview(statusImageView)
        briefStack.addArrangedSubview(statusImageView)

        unreadCountlabel = UILabel()
        unreadCountlabel.font = .systemFont(ofSize: 14)
        unreadCountlabel.textColor = .make(0x999999)
        briefStack.addArrangedSubview(unreadCountlabel)

        briefLabel = UILabel()
        briefLabel.font = .systemFont(ofSize: 14)
        briefLabel.textColor = .make(0x999999)
        briefStack.addArrangedSubview(briefLabel)


        noteStack = UIStackView()
        noteStack.axis = .horizontal
        noteStack.alignment = .center
        noteStack.spacing = 4
        contentView.addSubview(noteStack)

        badgeView = STBadgeView()
        noteStack.addArrangedSubview(badgeView)

        let mutedImage = UIImage(named: "chat/muted")
        mutedImageView = UIImageView()
        mutedImageView.image = mutedImage
        mutedImageView.tintColor = .make(0xDBDBDB)
        noteStack.addArrangedSubview(mutedImageView)

        unreadNoteView = UIView()
        unreadNoteView.backgroundColor = .systemRed
        unreadNoteView.clipsToBounds = true
        noteStack.addArrangedSubview(unreadNoteView)
    }
    
    func layoutElements(){
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalToConstant: 48),
        ])
        profileImageView.layer.cornerRadius = 24
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17),
        ])
        
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timestampLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -12),
            timestampLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
        ])
        
      
        briefStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            briefStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            briefStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7)
        ])
        
        noteStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noteStack.trailingAnchor.constraint(equalTo: timestampLabel.trailingAnchor),
            noteStack.centerYAnchor.constraint(equalTo: briefStack.centerYAnchor),
        ])
        
        unreadNoteView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            unreadNoteView.widthAnchor.constraint(equalToConstant: 8),
            unreadNoteView.heightAnchor.constraint(equalToConstant: 8),
        ])
        unreadNoteView.layer.cornerRadius = 4
    }
    
    func setChat(_ chat: STChat){
        if chat.isSticky{
            contentView.backgroundColor = .systemGray6
        }
        
        if !chat.isGroup{
            profileImageView.image = Self.singlePhoto
        }else{
            profileImageView.image = Self.groupPhoto
        }
        profileImageView.load(chat.photo)
        
        
        titleLabel.text = chat.title
        
        let timestamp = chat.timestamp
        timestampLabel.text = DateUtil.readable(timestamp)
        
        let status = chat.state
        switch status{
        case .sending:
            statusImageView.isHidden = false
            statusImageView.image = Self.sendingImage
            statusImageView.tintColor = .systemGray
        case .failed:
            statusImageView.isHidden = false
            statusImageView.image = Self.failedImage
            statusImageView.tintColor = .systemRed
        default:
            statusImageView.isHidden = true
        }
        
        briefLabel.text = chat.brief
                
        if chat.isMuted && chat.unreadCount > 0{
            unreadCountlabel.isHidden = false
            let text = "chat_messages".localized(chat.unreadCount)
            unreadCountlabel.text = "[\(text)]"
            
            unreadNoteView.isHidden = false
        }else{
            unreadCountlabel.isHidden = true
            unreadNoteView.isHidden = true
        }
        
        if !chat.isMuted && chat.unreadCount > 0{
            badgeView.count = chat.unreadCount
            badgeView.isHidden = false
        }else{
            badgeView.isHidden = true
        }

        if chat.isMuted{
            mutedImageView.isHidden = false
        }else{
            mutedImageView.isHidden = true
        }
        
    }
}
