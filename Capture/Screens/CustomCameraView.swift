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
                    if let data = photo.fileDataRepresentation() {
                        capturedImage = UIImage(data: data)
                        camera.session?.stopRunning()
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
        }
    }
}
