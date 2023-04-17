//
//  String+.swift
//  Startalk
//
//  Created by lei on 2023/2/21.
//

import Foundation
import XMPPClient

extension String{
    
    //MARK: localization
    
    var localized: String{
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(_ arguments: CVarArg...) -> String{
        let format = NSLocalizedString(self, comment: "")
        return String.localizedStringWithFormat(format, arguments)
    }
    
    
    //MARK: xmpp client
    
    var jid: XCJid?{
        XCJid(self)
    }
    
    func messageContent(_ type: XCMessageType?) -> XCMessageContent?{
        if let type = type{
           return XCMessage.makeContent(self, type: type)
        }else{
            return nil
        }
    }
}
