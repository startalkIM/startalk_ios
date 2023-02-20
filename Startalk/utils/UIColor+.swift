//
//  UIColor+.swift
//  Startalk
//
//  Created by lei on 2023/2/20.
//

import UIKit

extension UIColor{
    static func make(_ hex: UInt) -> UIColor{
        let red = CGFloat((hex >> 16) & 0xff) / 255
        let green = CGFloat((hex >> 8) & 0xff) / 255
        let blue = CGFloat(hex & 0xff) / 255
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
