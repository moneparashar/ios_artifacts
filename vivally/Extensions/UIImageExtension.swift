/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import Foundation
import AVFoundation

extension UIImage {
    func mergeWith(topImage: UIImage) -> UIImage {
        let bottomImage = self
        
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top
        
        UIGraphicsBeginImageContext(size)
        
        print("bottom image width \(bottomImage.size.width), height \(bottomImage.size.height)")
        print("top image width \(topImage.size.width), height \(topImage.size.height)")
        
        let areaSize = CGRect(x: 0, y: 0, width: bottomImage.size.width , height: bottomImage.size.height  )
        bottomImage.draw(in: areaSize)
        
        let area2Size = CGRect(x: 0, y: 0/*(topPadding ?? CGFloat(0))*/, width: bottomImage.size.width, height: bottomImage.size.height )
        let aspectFitSize = AVMakeRect(aspectRatio: topImage.size, insideRect: area2Size)
        topImage.draw(in: aspectFitSize, blendMode: .normal, alpha: 1.0)
        
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return mergedImage
    }
    
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}

public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
