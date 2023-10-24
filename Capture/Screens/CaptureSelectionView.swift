//
//  CaptureSelectionView.swift
//  Capture
//
//  Created by Deonte Kilgore on 10/23/23.
//

import SwiftUI
import AVFoundation

struct CaptureSelectionView: View {
    @State private var capturedImage: UIImage? = nil
    @State private var isCustomCameraViewPresented = false
    
    var body: some View {
        ZStack {
            if capturedImage != nil {
                Image(uiImage: capturedImage!)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                Color(uiColor: .systemBackground)
            }
            
            VStack {
                Spacer()
                
                Button {
                    isCustomCameraViewPresented.toggle()
                } label: {
                    Image(systemName: "camera.fill")
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Circle())
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
            }
        }
    }
}

#Preview {
    CaptureSelectionView()
}
