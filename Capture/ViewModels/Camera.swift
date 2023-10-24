//
//  Camera.swift
//  Capture
//
//  Created by Deonte Kilgore on 10/24/23.
//

import AVFoundation

class Camera {
    var session: AVCaptureSession?
    var delegate: AVCapturePhotoCaptureDelegate?
    
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    func start(delegate: AVCapturePhotoCaptureDelegate, completion: @escaping (Error?) -> ()) {
        self.delegate = delegate
        checkPermissions(completion: completion)
    }
    
    private func checkPermissions(completion: @escaping (Error?) -> ()) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self.setupCamera(completion: completion)
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupCamera(completion: completion)
        default:
            break
        }
    }
    
    private func setupCamera(completion: @escaping(Error?) -> ()) {
        // Create a session
        let session = AVCaptureSession()
        // Check for device input
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                DispatchQueue.global(qos: .background).async {
                    session.startRunning()
                }
                
                self.session = session
            } catch {
                completion(error)
            }
        }
    }
    
    func capturePhoto(with settings: AVCapturePhotoSettings = AVCapturePhotoSettings()) {
        output.capturePhoto(with: settings, delegate: delegate!)
    }
}
