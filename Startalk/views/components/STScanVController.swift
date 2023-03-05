//
//  STScanVController.swift
//  Startalk
//
//  Created by lei on 2023/3/3.
//

import UIKit

class STScanVController: STBaseScanVController{
    
    var scanView: STScanView!
    var isLightOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanView.hideLightButton()
    }
    
    override func makeView() -> STBaseScanView{
        scanView = STScanView()
        scanView.delegate = self
        return scanView
    }
    
    
    override func didCapture(_ value: String){
        print("qr code is ", value)
    }
    
   
    override func brightnessDetected(){
        if !isLightOn{
            if isDark{
                scanView.showLightButton()
            }else{
                scanView.hideLightButton()
            }
        }
    }
}

extension STScanVController: STScanViewDelegate{
    func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    func imageButtonTapped() {
        print("image button tapped")
    }
    
    func turnLightOn() {
        super.turnTorchOn()
        isLightOn = true
    }
    
    func turnLightOff() {
        super.turnTorchOff()
        isLightOn = false
    }
    
}
