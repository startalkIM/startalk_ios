//
//  ImageMessageCell.swift
//  Startalk
//
//  Created by lei on 2023/5/16.
//

import UIKit
import XMPPClient

class ImageMessageCell: BaseMessageCell{
    static let IDENTIFIER = "image"
    
    var imageContentView: MessageCellImageContent!
    
    override var delegate: BaseMessageCellDelegate?{
        didSet{
            imageContentView.delegate = delegate as? ImageMessageCellDelegate
        }
    }
    
    override func makeContentsView() -> UIView {
        imageContentView = MessageCellImageContent()
        return imageContentView
    }
    
    override func setMessage(_ message: STMessage, user: User?){
        super.setMessage(message, user: user)
        guard let content = message.content as? XCImageMessageContent else{
            return
        }
      
        let localFile = message.localFile
        imageContentView.setContent(content, localFile: localFile)
    }
    
    override class var identifiers: [String]{
        var identifiers = super.identifiers
        for i in identifiers.indices{
            identifiers[i] = "\(Self.IDENTIFIER)_\(identifiers[i])"
        }
        return identifiers
    }
    
    override class func makeIdentifier(message: STMessage) -> String{
        let identifier = super.makeIdentifier(message: message)
        return "\(Self.IDENTIFIER)_\(identifier)"
    }
    
    override class func parseIdentifier(_ identifier: String) -> (Bool, BaseMessageCell.LayoutType)? {
        let prefix = Self.IDENTIFIER + "_"
        if identifier.starts(with: prefix){
            let identifier = identifier.dropFirst(prefix.count)
            return super.parseIdentifier(String(identifier))
        }else{
            return nil
        }
    }
}

protocol ImageMessageCellDelegate: BaseMessageCellDelegate, MessageCellImageContentDelegate{
    
}
