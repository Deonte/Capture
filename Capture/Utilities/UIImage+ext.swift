//
//  UIImage+ext.swift
//  Capture
//
//  Created by Deonte Kilgore on 10/29/23.
//

import UIKit

extension UIImage {
    static func convert(from ciImage: CIImage) -> UIImage{
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}
