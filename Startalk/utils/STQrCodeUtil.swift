//
//  STQrCodeUtil.swift
//  Startalk
//
//  Created by lei on 2023/3/1.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class STQrCodeUtil{
    
    static let scale = UIScreen.main.scale
    
    static func makeImage(_ data: Data, size: CGFloat) -> UIImage?{
        let generator = CIFilter.qrCodeGenerator()
        generator.message = data
        let ciImage = generator.outputImage
        
        if var ciImage = ciImage{
            let transformScale = size * scale / ciImage.extent.size.width
            let transform = CGAffineTransform(scaleX: transformScale, y: transformScale)
            ciImage = ciImage.transformed(by: transform)
            
            return UIImage(ciImage: ciImage, scale: scale, orientation: .up)
        }else{
            return nil
        }
    }
}
