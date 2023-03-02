//
//  ScanViewController.swift
//  Startalk
//
//  Created by lei on 2023/3/1.
//

import UIKit
import AVFoundation

class STScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let logger = STLogger(STScanViewController.self)

    var scanView: STScanView{
        view as! STScanView
    }
    var captureSession: AVCaptureSession?
    
    override func loadView() {
        let scanView = makeView()
        self.view = scanView
        
        guard let session = makeCaptureSession() else{
            return
        }
        self.captureSession = session

        scanView.previewLayer.session = session
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
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
        if !scanView.isAnimating{
            scanView.startLineScan()
        }
    }
    
    func tryStopCapturing(){
        if captureSession?.isRunning == true{
            DispatchQueue.global().async { [self] in
                captureSession?.stopRunning()
            }
        }
        if scanView.isAnimating{
            scanView.stopLineScan()
        }
    }

}

extension STScanViewController{
    private func makeCaptureSession() -> AVCaptureSession?{
        let session = AVCaptureSession()

        guard let device = AVCaptureDevice.default(for: .video) else {
            logger.warn("Could not find default video capture device")
            return nil
        }
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
        
        scanView.stopLineScan()
        didCapture(stringValue)
    }
}


extension STScanViewController{
    
    func didCapture(_ value: String){
    }
    
    func makeView() -> STScanView{
        STScanView()
    }
}
