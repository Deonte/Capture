//
//  CaptureSelectionView.swift
//  Capture
//
//  Created by Deonte Kilgore on 10/23/23.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct CaptureSelectionView: View {
    @State private var capturedImage: UIImage? = nil
    @State private var isCustomCameraViewPresented = false
    @State private var selectedImage: UIImage? = nil
    @State private var selectedImageItem: PhotosPickerItem? = nil
    
    var body: some View {
        ZStack {
            if capturedImage != nil {
                Image(uiImage: capturedImage!)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .onAppear {
                        selectedImage = nil
                    }
            } else if selectedImage != nil  {
                Image(uiImage: selectedImage!)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .onAppear {
                        capturedImage = nil
                    }
            } else {
                Color(uiColor: .systemBackground)
            }
            
              
            VStack {
                Spacer()
                HStack {
                    Button {
                        isCustomCameraViewPresented.toggle()
                    } label: {
                        Image(systemName: "camera.fill")
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    
                    PhotosPicker(selection: $selectedImageItem, matching: .any(of: [.images, .not(.screenshots), .not(.videos)])) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom)
                .sheet(isPresented: $isCustomCameraViewPresented, content: {
                    CustomCameraView(capturedImage: $capturedImage)
                })
                .onChange(of: capturedImage) { oldValue, newValue in
                    if newValue != nil {
                        isCustomCameraViewPresented = false
                    }
                }
                .onChange(of: selectedImageItem) {
                    Task {
                        if let data = try? await selectedImageItem?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                                return
                            }
                        }
                        
                        print("Failed")
                    }
                }
            }
        }
    }
}

#Preview {
    CaptureSelectionView()
}
