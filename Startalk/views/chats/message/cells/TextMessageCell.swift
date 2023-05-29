//
//  TextMessageCell.swift
//  Startalk
//
//  Created by lei on 2023/5/16.
//

import UIKit
import XMPPClient

class TextMessageCell: BaseMessageCell{
    static let IDENTIFIER = "text"
    
    var textContentView: MessageCellTextContent!
    
    override func makeContentsView() -> UIView {
        textContentView = MessageCellTextContent()
        return textContentView
    }
    
    override func addElements() {
        super.addElements()
        if layoutType == .send{
            textContentView.backgroundColor = .make(0xC5EAEE)
        }else{
            textContentView.backgroundColor = .white
        }
    }
    
    override func setMessage(_ message: STMessage, user: User?){
        super.setMessage(message, user: user)
        guard let content = message.content as? XCTextMessageContent else{
            return
        }
        textContentView.setContent(content)
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

