//
//  CustomCameraView.swift
//  Capture
//
//  Created by Deonte Kilgore on 10/24/23.
//

import SwiftUI

struct CustomCameraView: View {
    let camera = Camera()
    @Binding var capturedImage: UIImage?
    @Environment(\.isPresented) private var isPresented
    
    var body: some View {
        ZStack {
            PreviewCameraView(camera: camera) { result in
                switch result {
                case .success(let photo):
                    if camera.cameraPosition == .Front {
                        if let data = photo.cgImageRepresentation() {
                            let image = CIImage(cgImage: data).oriented(forExifOrientation: 6)
                            let flippedImage = image.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
                            capturedImage = UIImage.convert(from: flippedImage)
                        }
                        camera.session?.stopRunning()
                    } else  if camera.cameraPosition == .Back {
                        if let data = photo.fileDataRepresentation() {
                            capturedImage = UIImage(data: data)
                        }
                    } else {
                        print("Error: No Image Data Found.")
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
            VStack {
                Spacer()
                cameraShutterButton
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    cameraSwitchButton
                }
            }
        }
    }
}

private extension CustomCameraView {
    var cancelButton: some View {
        Button("Cancel") {
            print("Dissmiss Camera")
        }
    }
    
    var cameraShutterButton: some View {
        Button {
            camera.capturePhoto()
        } label: {
            ZStack {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 60)
                Circle()
                    .stroke(lineWidth: 3)
                    .frame(width: 70)
                    .foregroundColor(.white)
            }
        }
    }
    
    var cameraSwitchButton: some View {
        Button {
            camera.switchCamera()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath.camera")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 33)
                .foregroundColor(.white)
        }
        .padding()
    }
}
