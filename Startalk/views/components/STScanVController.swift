//
//  STScanVController.swift
//  Startalk
//
//  Created by lei on 2023/3/3.
//

import UIKit
import UniformTypeIdentifiers

class STScanVController: STBaseScanVController{
    private static let IMAGE_TYPE = {
        if #available(iOS 14.0, *) {
            return UTType.image.identifier
        } else {
            return "public.image"
        }
    }()
    
    var completion: ((String) -> Void)?
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
        if let completion = completion{
            completion(value)
        }else{
            presentingViewController?.dismiss(animated: true)
        }
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
        showImagePicker(delegate: self)
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

extension STScanVController: UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[.originalImage] as? UIImage, let text = STQrCodeUtil.extractText(image){
            didCapture(text)
        }else{
            dismiss(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true)
    }
}

