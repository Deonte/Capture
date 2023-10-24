//
//  PreviewCameraView.swift
//  Capture
//
//  Created by Deonte Kilgore on 10/24/23.
//

import SwiftUI
import AVFoundation

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
        
        let viewController = UIViewController()
        viewController.view.backgroundColor = .black
        viewController.view.layer.addSublayer(camera.previewLayer)
        camera.previewLayer.frame = viewController.view.bounds
        
        return viewController
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, didFinishProcessingPhoto: didFinishProcessingPhoto)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        let parent: PreviewCameraView
        private var didFinishProcessingPhoto: (Result<AVCapturePhoto, Error>) -> ()
        
        init(_ parent: PreviewCameraView, didFinishProcessingPhoto: @escaping (Result<AVCapturePhoto, Error>) -> ()) {
            self.parent = parent
            self.didFinishProcessingPhoto = didFinishProcessingPhoto
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let error = error {
                didFinishProcessingPhoto(.failure(error))
                return
            }
            
            didFinishProcessingPhoto(.success(photo))
        }
    }
}
