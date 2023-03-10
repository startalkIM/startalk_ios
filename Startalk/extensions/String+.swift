//
//  String+.swift
//  Startalk
//
//  Created by lei on 2023/2/21.
//

import Foundation

extension String{
    var localized: String{
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(_ arguments: CVarArg...) -> String{
        let format = NSLocalizedString(self, comment: "")
        return String.localizedStringWithFormat(format, arguments)
    }
}
