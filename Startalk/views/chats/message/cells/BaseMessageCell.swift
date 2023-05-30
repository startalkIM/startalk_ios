//
//  BaseMessageCell.swift
//  Startalk
//
//  Created by lei on 2023/5/15.
//

import UIKit

class BaseMessageCell: UITableViewCell {
    static let PRIVATE_RECEIVE_IDENTIFIER = "private-receive"
    static let GROUP_RECEIVE_IDENTIFIER = "group-receive"
    static let SEND_IDENTIFIER = "send"

    static let SHOW_TIMESTAMP_IDENTIFIER = "show-timestamp"
    static let HIDE_TIMESTAMP_IDENTIFIER = "hide-timestamp"
    
    static let singlePhoto = UIImage(named: "chat/single_photo")
        
    
    var showTimestamp = false
    var layoutType = LayoutType.privateReceive
    
    var timestampLabel: UILabel!
    var photoImageView: UIImageView!
    var nameLabel: UILabel!
    var contentsView: UIView!
    var stateView: MessageStateView!
    
    var layoutGuide: UILayoutGuide!
    
    var delegate: BaseMessageCellDelegate?{
        didSet{
            stateView.delegate = delegate
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        if let reuseIdentifier = reuseIdentifier, let result = Self.parseIdentifier(reuseIdentifier){
            showTimestamp = result.0
            layoutType = result.1
        }
        
        addElements()
        layoutElements(showTimestamp: showTimestamp, layoutType: layoutType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeContentsView() -> UIView{
        UIView()
    }
    
    func addElements(){
        timestampLabel = UILabel()
        timestampLabel.font = .systemFont(ofSize: 14)
        timestampLabel.textColor = .systemGray
        contentView.addSubview(timestampLabel)
        
        photoImageView = UIImageView()
        photoImageView.clipsToBounds = true
        photoImageView.contentMode = .scaleAspectFill
        contentView.addSubview(photoImageView)
        
        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 13)
        nameLabel.textColor = .make(0x8c8c8c)
        contentView.addSubview(nameLabel)
        
        contentsView = makeContentsView()
        contentView.addSubview(contentsView)
        
        stateView = MessageStateView()
        contentView.addSubview(stateView)
    }
    
    func layoutElements(showTimestamp: Bool, layoutType: LayoutType) {
        layoutBasic(showTimestamp: showTimestamp)
        switch layoutType{
        case .privateReceive:
            layoutPrivateReceive()
        case .groupReceive:
            layoutGroupReceive()
        case .send:
            layoutSend()
        }
    }
    
    func layoutBasic(showTimestamp: Bool){
        layoutGuide = UILayoutGuide()
        contentView.addLayoutGuide(layoutGuide)
        
        NSLayoutConstraint.activate([
            layoutGuide.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            layoutGuide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            layoutGuide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        if showTimestamp{
            timestampLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                timestampLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                timestampLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            ])
            
            NSLayoutConstraint.activate([
                layoutGuide.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor, constant: 5)
            ])
        }else{
            timestampLabel.isHidden = true
            NSLayoutConstraint.activate([
                layoutGuide.topAnchor.constraint(equalTo: contentView.topAnchor)
            ])
        }
    }
    
    func layoutPrivateReceive(){
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 10),
            photoImageView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 5),
            photoImageView.widthAnchor.constraint(equalToConstant: 46),
            photoImageView.heightAnchor.constraint(equalToConstant: 46),
        ])
        photoImageView.layer.cornerRadius = 23
        
        nameLabel.isHidden = true
        
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentsView.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 10),
            contentsView.topAnchor.constraint(equalTo: photoImageView.topAnchor),
            contentsView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -20)
        ])
        
        stateView.isHidden = true
    }
    
    func layoutGroupReceive(){
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 10),
            photoImageView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 5),
            photoImageView.widthAnchor.constraint(equalToConstant: 46),
            photoImageView.heightAnchor.constraint(equalToConstant: 46),
        ])
        photoImageView.layer.cornerRadius = 23
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
        ])
        
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentsView.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 10),
            contentsView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            contentsView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -20)
        ])
        
        stateView.isHidden = true
    }
    
    func layoutSend(){
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoImageView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -10),
            photoImageView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 5),
            photoImageView.widthAnchor.constraint(equalToConstant: 46),
            photoImageView.heightAnchor.constraint(equalToConstant: 46),
        ])
        photoImageView.layer.cornerRadius = 23
        
        nameLabel.isHidden = true
        
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentsView.trailingAnchor.constraint(equalTo: photoImageView.leadingAnchor, constant: -10),
            contentsView.topAnchor.constraint(equalTo: photoImageView.topAnchor),
            contentsView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -20)
        ])
        
        stateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stateView.trailingAnchor.constraint(equalTo: contentsView.leadingAnchor, constant: -10),
            stateView.centerYAnchor.constraint(equalTo: contentsView.centerYAnchor),
            stateView.widthAnchor.constraint(equalToConstant: 15),
            stateView.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    func setMessage(_ message: STMessage, user: User?){
        timestampLabel.text = DateUtil.readable(message.timestamp, withTime: true)
        photoImageView.setSource(user?.photo, placeholder: Self.singlePhoto)
        nameLabel.text = user?.name ?? message.from.bare
        stateView.setMessage(message)
    }

    
    
    //MARK: identifiers
    
    class func makeIdentifier(message: STMessage) -> String{
        let part1 = message.showTimestamp ? SHOW_TIMESTAMP_IDENTIFIER : HIDE_TIMESTAMP_IDENTIFIER
        let part2: String
        if message.direction == .receive{
            if message.isGroup{
                part2 = GROUP_RECEIVE_IDENTIFIER
            }else{
                part2 = PRIVATE_RECEIVE_IDENTIFIER
            }
        }else{
            part2 = SEND_IDENTIFIER
        }
        return makeIdentifier(part1, part2, message.id)
    }
    
    class private func makeIdentifier(_ part1: String, _ part2: String, _ id: String) -> String{
        return "\(part1)_\(part2)_cell-\(id)"
    }
    
    class func parseIdentifier(_ identifier: String) -> (Bool, LayoutType)?{
        let parts = identifier.split(separator: "_")
        guard parts.count == 3 else{
            return nil
        }
        let showTimestamp: Bool
        switch parts[0]{
        case SHOW_TIMESTAMP_IDENTIFIER:
            showTimestamp = true
        case HIDE_TIMESTAMP_IDENTIFIER:
            showTimestamp = false
        default:
            return nil
        }
        
        let layoutType: LayoutType
        switch parts[1]{
        case PRIVATE_RECEIVE_IDENTIFIER:
            layoutType = .privateReceive
        case GROUP_RECEIVE_IDENTIFIER:
            layoutType = .groupReceive
        case SEND_IDENTIFIER:
            layoutType = .send
        default:
            return nil
        }
        return (showTimestamp, layoutType)
    }
}

extension BaseMessageCell{
    enum LayoutType{
        case privateReceive
        case groupReceive
        case send
    }
}

@objc
protocol BaseMessageCellDelegate: MessageStateViewDelegate{
    
}
