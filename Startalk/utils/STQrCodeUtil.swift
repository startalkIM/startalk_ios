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
    
    private static let scale = UIScreen.main.scale
    
    private static let detector: CIDetector = {
        let context = CIContext()
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        return CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)!
    }()
    
    static func makeImage(_ text: String, size: CGFloat) -> UIImage?{
        guard let data = text.data(using: .utf8) else{
            return nil
        }
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
    
    static func extractText(_ image: UIImage) -> String?{
        guard let ciImage = CIImage(image: image) else{
            return nil
        }
        let features = detector.features(in: ciImage)
        guard let feature = features.first as? CIQRCodeFeature else{
            return nil
        }
        return feature.messageString
    }
}
