//
//  STScanView.swift
//  Startalk
//
//  Created by lei on 2023/3/2.
//

import UIKit
import AVFoundation

class STBaseScanView: UIView {
    override class var layerClass: AnyClass{
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
           layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get {
            return previewLayer.session
        }
        set {
            previewLayer.session = newValue
        }
    }
    
    private let scanLine: STScanLineView
    var isAnimating = false
    
    var startPosition = 0.2
    var endPosition = 0.6
    
    override init(frame: CGRect) {
        scanLine = STScanLineView()
        super.init(frame: frame)
        
        scanLine.contentMode = .redraw
        addSubview(scanLine)
        
        previewLayer.videoGravity = .resizeAspectFill
        
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startLineScan(){
        scanLine.isHidden = false
        
        let distance = endPosition - startPosition
        let fadding: CGFloat = 1 / 16
        
        setLineFrame(startPosition)
        scanLine.layer.opacity = 0
        
        isAnimating = true
        UIView.animateKeyframes(withDuration: 2.5, delay: 0, options: .repeat) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: fadding) { [self] in
                setLineFrame(startPosition + distance * fadding)
                scanLine.layer.opacity = 1
            }
            let middelDuration: CGFloat =  1 - 2 * fadding
            UIView.addKeyframe(withRelativeStartTime: fadding, relativeDuration: middelDuration) { [self] in
                setLineFrame(endPosition - distance * fadding)
            }
            UIView.addKeyframe(withRelativeStartTime: 1 - fadding, relativeDuration: fadding) { [self] in
                setLineFrame(endPosition)
                scanLine.layer.opacity = 0
            }
        } completion: { [self] _ in
            isAnimating = false
        }
    }
    
    func stopLineScan(){
        scanLine.isHidden = true
    }
    
    private func setLineFrame(_ position: CGFloat){
        let safeFrame = safeAreaLayoutGuide.layoutFrame
        let width = safeFrame.width
        let height = safeFrame.height
        
        let lineWidth = width
        let lineHeight = width * (1 - sqrt(3) / 2)
        
        let x: CGFloat = safeFrame.origin.x
        let y = safeFrame.origin.y + height * position - lineHeight
        scanLine.frame = CGRect(x: x, y: y, width: lineWidth, height: lineHeight)
    }
}
