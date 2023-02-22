//
//  UIColor+.swift
//  Startalk
//
//  Created by lei on 2023/2/20.
//

import UIKit

extension UIColor{
    static var spectralGrayBlue: UIColor = .make(0x597A96)

    
    static func make(_ hex: UInt) -> UIColor{
        let red = CGFloat((hex >> 16) & 0xff) / 255
        let green = CGFloat((hex >> 8) & 0xff) / 255
        let blue = CGFloat(hex & 0xff) / 255
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage{
        return UIGraphicsImageRenderer(size: size).image { context in
            self.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
