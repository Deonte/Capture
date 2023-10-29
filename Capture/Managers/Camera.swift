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

enum FlashMode {
    case on
    case off
}

class Camera {
    var session: AVCaptureSession?
    var delegate: AVCapturePhotoCaptureDelegate?
    var currentFlashMode: FlashMode = .off
    
    var cameraPosition: CameraType = .Back
    var output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    public func start(delegate: AVCapturePhotoCaptureDelegate, completion: @escaping (Error?) -> ()) {
        self.delegate = delegate
        checkPermissions(completion: completion)
    }
    
    public func switchCamera() {
        if cameraPosition == .Back {
            cameraPosition = .Front
            session?.stopRunning()
            addVideoInput()
        } else {
            cameraPosition = .Back
            session?.stopRunning()
            addVideoInput()
        }
    }
    
    public func capturePhoto(with settings: AVCapturePhotoSettings = AVCapturePhotoSettings()) {
        switch currentFlashMode {
        case .on:
            let newSettings = AVCapturePhotoSettings()
            newSettings.flashMode = .on
            output.capturePhoto(with: newSettings, delegate: delegate!)
        case .off:
            output.capturePhoto(with: settings, delegate: delegate!)
        }
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
    
    private func configure(camera: AVCaptureDevice.Position, from session: AVCaptureSession) {
        output = AVCapturePhotoOutput()
        if let device: AVCaptureDevice = self.deviceWithMediaTypeWithPosition(mediaType: .video, position: camera) {
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
                previewLayer.connection?.videoRotationAngle = 90 // Portrait
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
    
    private func addVideoInput(from session: AVCaptureSession) {
        if cameraPosition == .Front {
            configure(camera: .front, from: session)
        } else {
            configure(camera: .back, from: session)
        }
    }
    
    private func setupCamera(completion: @escaping(Error?) -> ()) {
        addVideoInput()
    }
    
    private func deviceWithMediaTypeWithPosition(mediaType: AVMediaType, position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera], mediaType: mediaType, position: .back)
        let frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera], mediaType: mediaType, position: .front)
        var discoverySession: AVCaptureDevice.DiscoverySession?
        
        if position == .unspecified || position == .back {
            discoverySession = backVideoDeviceDiscoverySession
        } else {
            discoverySession = frontVideoDeviceDiscoverySession
        }
        
        if discoverySession!.devices.count != 0 {
            if var captureDevice: AVCaptureDevice = discoverySession!.devices.first {
                
                for device in discoverySession!.devices {
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
    
    private func addVideoInput() {
        let session = AVCaptureSession()
        addVideoInput(from: session)
    }
    
}
