//
//  Camera.swift
//  Capture
//
//  Created by Deonte Kilgore on 10/24/23.
//

import AVFoundation

enum CameraType {
    case Front
    case Back
}

class Camera {
    var session: AVCaptureSession?
    var delegate: AVCapturePhotoCaptureDelegate?
    var cameraCheck: CameraType = .Back
    
    var output = AVCapturePhotoOutput()
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
            DispatchQueue.main.async {
                self.setupCamera(completion: completion)
            }
        default:
            break
        }
    }
    
    private func addVideoInput(from session: AVCaptureSession) {
        if cameraCheck == .Front {
            output = AVCapturePhotoOutput()
            if let device: AVCaptureDevice = self.deviceWithMediaTypeWithPosition(mediaType: .video, position: .front) {
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    if session.canAddInput(input) {
                        session.addInput(input)
                    }
                    if session.canAddOutput(output) {
                        session.addOutput(output)
                    }
                    
                    if device.isFocusModeSupported(.continuousAutoFocus) {
                        try device.lockForConfiguration()
                        device.focusMode = .continuousAutoFocus
                        device.unlockForConfiguration()
                    }
                    previewLayer.videoGravity = .resizeAspectFill
                    previewLayer.session = session
                    
                    DispatchQueue.global(qos: .background).async {
                        session.startRunning()
                    }
                    session.sessionPreset = .photo

                    self.session = session
                } catch {
                    print(error)
                }
            }
        } else {
            if let device: AVCaptureDevice = self.deviceWithMediaTypeWithPosition(mediaType: .video, position: .back) {
                output = AVCapturePhotoOutput()
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    if session.canAddInput(input) {
                        session.addInput(input)
                    }
                    if session.canAddOutput(output) {
                        session.addOutput(output)
                    }
                    
                    if device.isFocusModeSupported(.continuousAutoFocus) {
                        try device.lockForConfiguration()
                        device.focusMode = .continuousAutoFocus
                        device.unlockForConfiguration()
                    }
                    previewLayer.videoGravity = .resizeAspectFill
                    previewLayer.session = session
                    session.sessionPreset = .photo

                    DispatchQueue.global(qos: .background).async {
                        session.startRunning()
                    }
                    
                    self.session = session
                } catch {
                    print(error)
                }
                
            }
        }
    }
    
    private func setupCamera(completion: @escaping(Error?) -> ()) {
        let session = AVCaptureSession()
        addVideoInput(from: session)
    }
    
    func deviceWithMediaTypeWithPosition(mediaType: AVMediaType, position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: mediaType, position: .unspecified)
        if discoverySession.devices.count != 0 {
            if var captureDevice: AVCaptureDevice = discoverySession.devices.first {

                for device in discoverySession.devices {
                    let d = device
                    if d.position == position {
                        captureDevice = d
                        break;
                    }
                }
                print(captureDevice)
                return captureDevice
            }
        }
        print("doesnt have any camera")
        return nil
    }
    
    func flipCamera() {
        let session = AVCaptureSession()
        addVideoInput(from: session)
    }
    
    func capturePhoto(with settings: AVCapturePhotoSettings = AVCapturePhotoSettings()) {
        output.capturePhoto(with: settings, delegate: delegate!)
    }
}
