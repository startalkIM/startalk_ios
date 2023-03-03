//
//  STScanLineView.swift
//  Startalk
//
//  Created by lei on 2023/3/2.
//

import UIKit

class STScanLineView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
    private func _init(){
        isOpaque = false
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else{
            return
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let startColor = UIColor.systemGreen.cgColor
        let endColor = UIColor.systemGreen.withAlphaComponent(0).cgColor
        var colorComponents: [CGFloat] = startColor.components! + endColor.components!
        
        var locations: [CGFloat] = [0, 1]
        
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: &colorComponents, locations: &locations, count: locations.count)
        guard let gradient = gradient else{
            return
        }
        
        let width = rect.width
        let height = rect.height
        let startCenter = CGPoint(x: width / 2, y: height)
        let startRadius: CGFloat = 0
        let endCenter = CGPoint(x: width / 2, y: height + sqrt(3) / 2 * width)
        let endRadius = width
        
        context.drawRadialGradient(gradient, startCenter: startCenter, startRadius: startRadius, endCenter: endCenter, endRadius: endRadius, options: [])
    }
    

}
