//
//  CameraViewModel.swift
//  Capture
//
//  Created by Deonte Kilgore on 10/23/23.
//

import AVFoundation
import SwiftUI

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var isTaken: Bool = false
    var session = AVCaptureSession()
    @Published var alert: Bool = false
    var photoOutput = AVCapturePhotoOutput()
    var preview: AVCaptureVideoPreviewLayer!
    @Published var isSaved: Bool  = false
    var photoData: Data = Data()
    
    func checkPermissions() {
        // Check Permission to use camera.
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            #warning("Come Back to take error message.")
            print("Error: Permission has been denied, in order to use camera please update apps permissions in settings.")
            self.alert.toggle()
            return
        case .notDetermined:
            // Request Permission.
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    self.setup()
                }
            }
            return
        case .authorized:
            setup()
            return
        default:
            print("An unknown error has occured.")
            return
        }
    }
    
    func setup() {
        DispatchQueue.global(qos: .background).async {
        // Start Configuring Settings
        self.session.beginConfiguration()
        // Check for Back Camera
        guard let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back),
        // Try to access the devices camera, if none is detected return to avoid crash.
        let input = try? AVCaptureDeviceInput(device: device) else {
            print("Error No Camera Detected.")
            return
        }
        // If the system detects a working camera, add it as an input.
        if self.session.canAddInput(input) {
            self.session.addInput(input)
        }
        // Add the output from the session.
        if self.session.canAddOutput(self.photoOutput) {
            self.session.addOutput(self.photoOutput)
        }
        // Commit the configuration settings.
        self.session.commitConfiguration()
        // Start Session
            self.session.startRunning()
        }
    }
    
    // Taking a Photo
    func takePhoto() {
        DispatchQueue.global(qos: .background).async {
            self.photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            self.session.stopRunning()
            
            DispatchQueue.main.async {
                withAnimation {
                    self.isTaken.toggle()
                }
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            print("An error occured")
            return
        }
        
        print("Photo taken and processed.")
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        self.photoData = imageData
    }
    
    func savePhoto() {
        let image = UIImage(data: self.photoData)!
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        self.isSaved = true
        
        print("Saved Successfully...")
    }
    
    func retakePhoto() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            
            DispatchQueue.main.async {
                withAnimation {
                    self.isTaken.toggle()
                    // Clear the Photo from memory
                    self.isSaved = false
                }
            }
        }
    }
}
