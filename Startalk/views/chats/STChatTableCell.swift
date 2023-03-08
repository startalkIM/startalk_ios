//
//  STChatCell.swift
//  Startalk
//
//  Created by lei on 2023/3/8.
//

import UIKit

class STChatTableCell: UITableViewCell {
    static let IDENTIFIER  = "chat_cell"
    
    
    var stickyView: UIView!
    var profileImageView: UIImageView!
    var titleLabel: UILabel!
    var timestampLabel: UILabel!
    var statusImageView: UIImageView!
    var unreadCountlabel: UILabel!
    var briefLabel: UILabel!
    var badgeView: STBadgeView!
    var muteImageView: UIImageView!
    var unreadNoteView: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addElements(){
        let imageView = UIImageView()
        //imageView.layer
    }
    
    func layoutElements(){
        
    }
}
