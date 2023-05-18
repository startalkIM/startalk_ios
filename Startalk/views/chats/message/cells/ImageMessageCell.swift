//
//  ImageMessageCell.swift
//  Startalk
//
//  Created by lei on 2023/5/16.
//

import UIKit
import XMPPClient

class ImageMessageCell: BaseMessageCell{
    
    var imageContentView: MessageCellImageContent!
    
    var delegate: MessageCellImageContentDelegate?{
        didSet{
            imageContentView.delegate = delegate
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
}


class PrivateReceiveImageMessageCell: ImageMessageCell{
    static let IDENTIFIER = "private_receive_image_message_cell"
    
    override func makeLayout() -> MessgeCellLayout? {
        PrivateReceiveMessageCellLayout()
    }
}

class GroupReceiveImageMessageCell: ImageMessageCell{
    static let IDENTIFIER = "group_receive_image_message_cell"
    
    override func makeLayout() -> MessgeCellLayout? {
        GroupReceiveMessageCellLayout()
    }
}

class SendImageMessageCell: ImageMessageCell{
    static let IDENTIFIER = "send_image_message_cell"

    override func makeLayout() -> MessgeCellLayout? {
        SendMessageCellLayout()
    }
}
