//
//  CameraView.swift
//  Capture
//
//  Created by Deonte Kilgore on 10/23/23.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var camera = CameraViewModel()
    var body: some View {
        ZStack {
            CameraPreview(camera: camera)
                .ignoresSafeArea()
            
            VStack {
                HStack {
//                    // Dismiss Button
//                    Button {
//                        // Save photo and ready view for another photo.
//                    } label: {
//                        Image(systemName: "xmark")
//                            .foregroundColor(.black)
//                            .padding()
//                            .background(Color.white)
//                            .clipShape(Circle())
//                    }
//                    .padding(.leading, 10)
                    
                    Spacer()
                    
                if camera.isTaken {
                        Button {
                            // Retake Photo
                            camera.retakePhoto()
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 10)
                    }
                }
                
                Spacer()
                
                HStack {
                    if camera.isTaken  {
                        Button {
                            // Save photo and ready view for another photo.
                            if !camera.isSaved {
                                camera.savePhoto()
                            }
                        } label: {
                            Text(camera.isSaved ? "Saved" : "Save")
                                .foregroundColor(Color.black)
                                .fontWeight(.semibold)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                        .padding(.leading)
                        
                        Spacer()
                    } else {
                      shutterButton
                    }
                }
            }
        }
        .onAppear {
            camera.checkPermissions()
        }
    }
}

private extension CameraView {
    var shutterButton: some View {
        Button {
            // Take Photo...
            camera.takePhoto()
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

// Camera Preview ViewPort
struct CameraPreview: UIViewRepresentable {
    var camera: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        
        let view = UIView(frame: UIScreen.main.bounds)
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

//#Preview {
//    CameraView()
//}

