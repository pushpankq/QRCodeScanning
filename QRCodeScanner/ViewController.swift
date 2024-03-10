//
//  ViewController.swift
//  QRCodeScanner
//
//  Created by Pushpank Kumar on 09/03/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    let session = AVCaptureSession()
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var outputLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCamera()
        
        previewView.layer.borderColor = UIColor.white.cgColor
        previewView.layer.borderWidth = 3

    }

}

private extension ViewController {
    
    func setUpCamera() {
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("videoNotSupported", QRScannerError.videoNotSupported)
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            guard session.canAddInput(input) else {
                print("cannotAddSessionCaptureDeviceInput ", QRScannerError.cannotAddSessionCaptureDeviceInput)
                return
            }
            
            session.addInput(input)
            
            
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: .main)
            
            session.addOutput(output)
            
            output.metadataObjectTypes = [.ean13,
                                          .ean8,
                                          .upce,
                                          .code39,
                                          .code128,
                                          .pdf417,
                                          .qr]
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = previewView.bounds
            previewView.layer.addSublayer(previewLayer)
            
            let queue = DispatchQueue(label: "label.background", qos: .background)
            queue.async {
                self.session.startRunning()
            }

        } catch  {
            print("error ", QRScannerError.unableToCrateCaptureDeviceInput)
        }
    }
}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else { return }
        session.stopRunning()
        self.outputLabel.text = stringValue
    }
}

enum QRScannerError {
    case videoNotSupported
    case unableToCrateCaptureDeviceInput
    case cannotAddSessionCaptureDeviceInput
}
