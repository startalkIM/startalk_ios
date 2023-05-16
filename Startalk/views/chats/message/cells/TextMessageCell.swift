//
//  TextMessageCell.swift
//  Startalk
//
//  Created by lei on 2023/5/16.
//

import UIKit
import XMPPClient

class TextMessageCell: BaseMessageCell{
    
    var textContentView: MessageCellTextContent!
    
    override func makeContentsView() -> UIView {
        textContentView = MessageCellTextContent()
        return textContentView
    }
    
    override func setMessage(_ message: STMessage, user: User?){
        super.setMessage(message, user: user)
        guard let content = message.content as? XCTextMessageContent else{
            return
        }
        textContentView.setContent(content)
    }
    
}


class PrivateReceiveTextMessageCell: TextMessageCell{
    static let IDENTIFIER = "private_receive_text_message_cell"
    
    override func addElements() {
        super.addElements()
        textContentView.backgroundColor = .white
    }
    
    override func makeLayout() -> MessgeCellLayout? {
        PrivateReceiveMessageCellLayout()
    }
}

class GroupReceiveTextMessageCell: TextMessageCell{
    static let IDENTIFIER = "group_receive_text_message_cell"
    
    override func addElements() {
        super.addElements()
        textContentView.backgroundColor = .white
    }
    
    override func makeLayout() -> MessgeCellLayout? {
        GroupReceiveMessageCellLayout()
    }
}

class SendTextMessageCell: TextMessageCell{
    static let IDENTIFIER = "send_text_message_cell"

    override func addElements() {
        super.addElements()
        textContentView.backgroundColor = .make(0xC5EAEE)
    }
    
    override func makeLayout() -> MessgeCellLayout? {
        SendMessageCellLayout()
    }
}

