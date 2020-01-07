//
//  UIImage.swift
//  Quick Quips
//
//  Created by Taylor Ray Howard on 6/10/19.
//  Copyright © 2019 Taylor Howard. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

extension UIImage {
    func fixOrientation() -> UIImage {
        let img = self
        if (img.imageOrientation == .up) {
            return img
        }

        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)

        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return normalizedImage
    }
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ jpegQuality: JPEGQuality) -> UIImage {
        return UIImage(data: jpegData(compressionQuality: jpegQuality.rawValue)!)!
    }
}
