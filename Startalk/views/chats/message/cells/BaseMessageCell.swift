//
//  BaseMessageCell.swift
//  Startalk
//
//  Created by lei on 2023/5/15.
//

import UIKit

class BaseMessageCell: UITableViewCell {
    static let ESTIMATED_HEIGHT: CGFloat = 80
    
    static let singlePhoto = UIImage(named: "chat/single_photo")
        
    var photoImageView: UIImageView!
    var nameLabel: UILabel!
    var contentsView: UIView!
    var stateView: MessageStateView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        addElements()
        layoutElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeContentsView() -> UIView{
        UIView()
    }
    
    func makeLayout() -> MessgeCellLayout? {
        nil
    }
    
    func addElements(){
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
    
    func layoutElements() {
        if let layout = makeLayout(){
            layout.layout(photoImageView: photoImageView, nameLabel: nameLabel, contentsView: contentsView, contentView: contentView, stateView: stateView)
        }
    }
    
    func setMessage(_ message: STMessage, user: User?){
        photoImageView.setSource(user?.photo, placeholder: Self.singlePhoto)
        nameLabel.text = user?.name ?? message.from.bare
        stateView.setState(message.state)
    }
}
