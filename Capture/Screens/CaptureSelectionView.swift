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
            VStack {
                if capturedImage != nil {
                    HStack {
                        Spacer()
                        Button {
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: capturedImage!)
                        } label: {
                            Text("Save")
                                .padding(10)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(.horizontal)
                    }
                }
                
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
        .background {
            if capturedImage != nil {
                Image(uiImage: capturedImage!)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .onAppear {
                        selectedImage = nil
                    }
            } else {
                Color(uiColor: .systemBackground)
            }
            
            if selectedImage != nil  {
                Image(uiImage: selectedImage!)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .onAppear {
                        capturedImage = nil
                    }
            } 
        }
    }
}

#Preview {
    CaptureSelectionView()
}
