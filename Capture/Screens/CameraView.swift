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
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                flashButton
                Spacer()
            }
            .padding()
            .background(.black)
            
            Rectangle()
                .foregroundColor(.blue)
            
            HStack {
                cancelButton
                Spacer()
                cameraShutterButton
                Spacer()
                cameraSwitchButton
            }
            .padding()
            .background(Color.black)
        }
    }
}

#Preview {
    CameraView()
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
                .clipShape(Circle())        }
    }
    
    var flashButton: some View {
        Button {
            withAnimation {
                isFlashOn.toggle()
            }
            //camera.toggleFlash()
        } label: {
            Image(systemName: "bolt.fill")
                .font(.title2)
                .frame(width: 44, height: 44)
                .foregroundColor(isFlashOn ? .yellow : .white)
        }
    }
}
