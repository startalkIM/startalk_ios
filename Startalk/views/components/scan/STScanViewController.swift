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
    var captureSession: AVCaptureSession!
    
    override func loadView() {
        let scanView = STScanView()
        guard let session = makeCaptureSession() else{
            return
        }
        scanView.previewLayer.session = session
        
        self.view = scanView
        self.captureSession = session
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !captureSession.isRunning{
            DispatchQueue.global().async { [self] in
                captureSession.startRunning()
            }
        }
        scanView.startLineScan()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession.isRunning{
            DispatchQueue.global().async { [self] in
                captureSession.stopRunning()
            }
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        guard let metadataObject = metadataObjects.first else{ return }
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
        guard let stringValue = readableObject.stringValue else { return }
        
        scanView.stopLineScan()
        didCapture(stringValue)
    }

    override var prefersStatusBarHidden: Bool {
        return true
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
}


extension STScanViewController{
    
    func didCapture(_ value: String){
        print("captureed ", value)
    }
}
