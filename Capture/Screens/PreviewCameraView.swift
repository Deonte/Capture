//
//  PreviewCameraView.swift
//  Capture
//
//  Created by Deonte Kilgore on 10/24/23.
//

import SwiftUI
import AVFoundation
import UIKit

class CameraViewController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = .black
    }
}

struct PreviewCameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    let camera: Camera
    let didFinishProcessingPhoto: (Result<AVCapturePhoto, Error>) -> ()
    
    func makeUIViewController(context: Context) -> UIViewController {
        camera.start(delegate: context.coordinator) { error in
            if let error = error {
                didFinishProcessingPhoto(.failure(error))
                return
            }
        }
        
        let viewController = context.coordinator.viewController
        viewController.view.layer.addSublayer(camera.previewLayer)
        camera.previewLayer.frame = viewController.view.bounds
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator,
                                                action: #selector(context.coordinator.handleTap(_:)))
        viewController.view.addGestureRecognizer(tapGesture)
        
        return viewController
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewController: CameraViewController(), didFinishProcessingPhoto: didFinishProcessingPhoto)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        let parent: PreviewCameraView
        private var didFinishProcessingPhoto: (Result<AVCapturePhoto, Error>) -> ()
        let viewController: CameraViewController
        
        init(_ parent: PreviewCameraView, viewController: CameraViewController, didFinishProcessingPhoto: @escaping (Result<AVCapturePhoto, Error>) -> ()) {
            self.parent = parent
            self.viewController = viewController
            self.didFinishProcessingPhoto = didFinishProcessingPhoto
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let error = error {
                didFinishProcessingPhoto(.failure(error))
                return
            }
            
            didFinishProcessingPhoto(.success(photo))
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let previewLayer = parent.camera.previewLayer
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            
            let touchPoint: CGPoint = gesture.location(in: viewController.view)
            let convertedPoint: CGPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)
            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
                do {
                    try device.lockForConfiguration()
                    device.focusPointOfInterest = convertedPoint
                    device.focusMode = AVCaptureDevice.FocusMode.autoFocus
                    device.unlockForConfiguration()
                } catch {
                    print("unable to focus")
                }
            }
            let location = gesture.location(in: viewController.view)
            let x = location.x - 125
            let y = location.y - 125
            let lineView = DrawSquare(frame: CGRect(x: x, y: y, width: 250, height: 250))
            lineView.backgroundColor = UIColor.clear
            lineView.alpha = 0.9
            viewController.view.addSubview(lineView)
            
            DrawSquare.animate(withDuration: 1, animations: {
                lineView.alpha = 1
            }) { (success) in
                lineView.alpha = 0
            }
        }
    }
}

class DrawSquare: UIView {
    
    override func draw(_ rect: CGRect) {
        let h = rect.height
        let w = rect.width
        let color:UIColor = UIColor.yellow
        
        let drect = CGRect(x: (w * 0.25),y: (h * 0.25),width: (w * 0.5),height: (h * 0.5))
        let bpath:UIBezierPath = UIBezierPath(rect: drect)
        
        color.set()
        bpath.stroke()
    }
    
}
