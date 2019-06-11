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
        let imageOrientation = self.imageOrientation
        
        var transform: CGAffineTransform = .identity
        
        switch imageOrientation {
        case .up:
            return self
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width ,y: size.height).rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0).rotated(by: .pi)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height).rotated(by: -.pi/2)
        case .upMirrored:
            transform = transform.translatedBy(x: size.width, y: 0).scaledBy(x: -1, y: 1)
        default: break
        }
        
        guard let cgImage = cgImage, let colorSpace = cgImage.colorSpace,
            let context: CGContext = CGContext(data: nil,
                                               width: Int(size.width),
                                               height: Int(size.height),
                                               bitsPerComponent: cgImage.bitsPerComponent,
                                               bytesPerRow: 0,
                                               space: colorSpace,
                                               bitmapInfo: cgImage.bitmapInfo.rawValue)
            else { return self }
        context.concatenate(transform)
        var rect: CGRect
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            rect = CGRect(x: 0, y: 0, width: size.height, height: size.width)
        default:
            rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
        context.draw(cgImage, in: rect)
        guard let image = context.makeImage() else { return self }
        return UIImage(cgImage: image)
    }
    
}
