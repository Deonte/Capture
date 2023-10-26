//
//  ImageSaver.swift
//  Capture
//
//  Created by Deonte Kilgore on 10/26/23.
//

import UIKit
import Photos

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError: Error?, contextInfo: UnsafeRawPointer) {
        if let error = didFinishSavingWithError {
            print(error.localizedDescription)
            return
        }
        
        print("Save Finish")
    }
}
