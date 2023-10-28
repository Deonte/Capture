//
//  CustomCameraView.swift
//  Capture
//
//  Created by Deonte Kilgore on 10/24/23.
//

import SwiftUI

extension UIImage {
    static func convert(from ciImage: CIImage) -> UIImage{
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}

struct CustomCameraView: View {
    let camera = Camera()
    @Binding var capturedImage: UIImage?
    @Environment(\.isPresented) private var isPresented
    
    var body: some View {
        ZStack {
            PreviewCameraView(camera: camera) { result in
                switch result {
                case .success(let photo):
                    if camera.cameraCheck == .Front {
                        if let data = photo.cgImageRepresentation() {
                            let image = CIImage(cgImage: data).oriented(forExifOrientation: 6)
                            let flippedImage = image.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
                            capturedImage = UIImage.convert(from: flippedImage)
                        }
                        camera.session?.stopRunning()
                    } else  if camera.cameraCheck == .Back {
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
            
            VStack {
                Spacer()
               
                HStack {
                    Spacer()
                    Button {
                        switchCamera()
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
        }
    }
    
    func switchCamera() {
        if camera.cameraCheck == .Back {
            camera.cameraCheck = .Front
            camera.session?.stopRunning()
            camera.flipCamera()
        } else {
            camera.cameraCheck = .Back
            camera.session?.stopRunning()
            camera.flipCamera()
        }
    }
}
