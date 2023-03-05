//
//  ScanViewController.swift
//  Startalk
//
//  Created by lei on 2023/3/1.
//

import UIKit
import AVFoundation

class STBaseScanVController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    static let LIGHT_MONITOR_INTERVAL: Double = 1
    let logger = STLogger(STBaseScanVController.self)

    var baseScanView: STBaseScanView{
        view as! STBaseScanView
    }
    var captureDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var timer: Timer?
    var isDark: Bool = false
    
    override func loadView() {
        let scanView = makeView()
        self.view = scanView
        
        guard let device = AVCaptureDevice.default(for: .video) else{
            return
        }
        self.captureDevice = device
        
        guard let session = makeCaptureSession(device) else{
            return
        }
        self.captureSession = session

        scanView.session = session
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .denied{
            showAlert(message: "camera_access_unauthorized".localized)
            return
        }
        
        tryStartCapturing()
    }

    override func viewWillDisappear(_ animated: Bool) {
        tryStopCapturing()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc
    func receiveForeground(_ notification: Notification){
        tryStartCapturing()
    }
    
    func tryStartCapturing(){
        if captureSession?.isRunning == false{
            DispatchQueue.global().async { [self] in
                captureSession?.startRunning()
            }
        }
        if !baseScanView.isAnimating{
            baseScanView.startLineScan()
        }
        if timer == nil, let device = captureDevice{
            startLightDecting(device)
        }
    }
    
    func tryStopCapturing(){
        if captureSession?.isRunning == true{
            DispatchQueue.global().async { [self] in
                captureSession?.stopRunning()
            }
        }
        if baseScanView.isAnimating{
            baseScanView.stopLineScan()
        }
        
        timer?.invalidate()
        timer = nil
    }
    
    
    //MARK: functions should overridden by child class
    
    func makeView() -> STBaseScanView{
        STBaseScanView()
    }
    
    
    func didCapture(_ value: String){
    }
    
    
    func brightnessDetected(){
    }
}

extension STBaseScanVController{
    private func makeCaptureSession(_ device: AVCaptureDevice) -> AVCaptureSession?{
        let session = AVCaptureSession()
        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
            logger.warn("Hint error making capture input", error)
            return nil
        }

        if (session.canAddInput(input)) {
            session.addInput(input)
        } else {
            logger.warn("Could not add input to session")
        }

        let output = AVCaptureMetadataOutput()
        if (session.canAddOutput(output)) {
            session.addOutput(output)
            output.metadataObjectTypes = [.qr]
            output.setMetadataObjectsDelegate(self, queue: .main)
        } else {
            logger.warn("Could not add output to session")
            return nil
        }
        
        return session
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession?.stopRunning()

        guard let metadataObject = metadataObjects.first else{ return }
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
        guard let stringValue = readableObject.stringValue else { return }
        
        baseScanView.stopLineScan()
        didCapture(stringValue)
    }
    
    func turnTorchOn(){
        configureDevice { device in
            if device.hasTorch && device.isTorchAvailable{
                try device.setTorchModeOn(level: 0.5)
            }
        }
    }
    
    func turnTorchOff(){
        configureDevice { device in
            if device.hasTorch && device.isTorchAvailable{
                device.torchMode = .off
            }
        }
    }
    
    private func configureDevice(_ block: (AVCaptureDevice) throws -> Void){
        if let device = captureDevice{
            
            do{
                try device.lockForConfiguration()
            }catch{
                logger.warn("Hit error congiguring capture device", error)
                return
            }
            
            do{
               try block(device)
            }catch{
                logger.warn("Hit error congiguring capture device", error)
            }
            
            device.unlockForConfiguration()
        }
    }
    
    func startLightDecting(_ device: AVCaptureDevice){
        let interval = Self.LIGHT_MONITOR_INTERVAL
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true){ [self] _ in
            isDark = (device.iso == device.activeFormat.maxISO)
            brightnessDetected()
        }
    }
}
