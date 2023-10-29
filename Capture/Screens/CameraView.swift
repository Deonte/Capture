//
//  CameraView.swift
//  Capture
//
//  Created by Deonte Kilgore on 10/29/23.
//

import SwiftUI

struct CameraView: View {
    let camera = Camera()
    @State private var isFlashOn = false
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
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
            
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    flashButton
                    Spacer()
                }
                .padding()
                .background(.black.opacity(0.7))
                
                Spacer()
                
                HStack {
                    cancelButton
                    Spacer()
                    cameraShutterButton
                    Spacer()
                    cameraSwitchButton
                }
                .padding()
                .background(.black.opacity(0.7))
            }

        }
    }
}

private extension CameraView {
    var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
        .foregroundStyle(Color.white)
    }
    
    var cameraShutterButton: some View {
        Button {
           camera.capturePhoto()
        } label: {
            ZStack {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 55)
                Circle()
                    .stroke(lineWidth:5)
                    .frame(width: 65)
                    .foregroundColor(.white)
            }
        }
    }
    
    var cameraSwitchButton: some View {
        Button {
            camera.switchCamera()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.title3)
                .frame(width: 44, height: 44)
                .foregroundColor(.white)
                .background(Color(uiColor: .white.withAlphaComponent(0.1)))
                .clipShape(Circle())
        }
    }
    
    var flashButton: some View {
        Button {
            withAnimation {
                if isFlashOn == false {
                    isFlashOn = true
                    camera.currentFlashMode = .on
                } else {
                    isFlashOn = false
                    camera.currentFlashMode = .off
                }
            }
        } label: {
            Image(systemName: "bolt.fill")
                .font(.title2)
                .frame(width: 44, height: 44)
                .foregroundColor(isFlashOn ? .yellow : .white)
        }
    }
}
