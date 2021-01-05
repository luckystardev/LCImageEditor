//
//  LCImageEditorExtensions.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics

// MARK: - UIImage extension

extension UIImage {
    func resize(toSizeInPixel: CGSize) -> UIImage {
        let screenScale = UIScreen.main.scale
        let sizeInPoint = CGSize(width: toSizeInPixel.width / screenScale,
                                 height: toSizeInPixel.height / screenScale)
        return resize(toSizeInPoint: sizeInPoint)
    }
    
    func resize(toSizeInPoint: CGSize) -> UIImage {
        let size = self.size
        var newImage: UIImage
        
        let widthRatio  = toSizeInPoint.width  / size.width
        let heightRatio = toSizeInPoint.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: newSize.width, height: newSize.height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
            self.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
    
    func cgImageWithFixedOrientation() -> CGImage? {
        
        guard let cgImage = self.cgImage, let colorSpace = cgImage.colorSpace else {
            return nil
        }
        
        if self.imageOrientation == UIImage.Orientation.up {
            return self.cgImage
        }
        
        let width  = self.size.width
        let height = self.size.height
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: width, y: height)
            transform = transform.rotated(by: CGFloat.pi)
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.rotated(by: 0.5 * CGFloat.pi)
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: height)
            transform = transform.rotated(by: -0.5 * CGFloat.pi)
            
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default:
            break
        }
        
        guard let context = CGContext(
            data: nil,
            width: Int(width),
            height: Int(height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: UInt32(cgImage.bitmapInfo.rawValue)
            ) else {
                return nil
        }
        
        context.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
            
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        
        guard let newCGImg = context.makeImage() else {
            return nil
        }
        
        return newCGImg
    }
}


// MARK: - CGImage extension

extension CGImage {
    func transformedImage(_ transform: CGAffineTransform, zoomScale: CGFloat, sourceSize: CGSize, cropSize: CGSize, imageViewSize: CGSize) -> CGImage {
        let expectedWidth = floor(sourceSize.width / imageViewSize.width * cropSize.width) / zoomScale
        let expectedHeight = floor(sourceSize.height / imageViewSize.height * cropSize.height) / zoomScale
        let outputSize = CGSize(width: expectedWidth, height: expectedHeight)
        let bitmapBytesPerRow = 0
        
        let context = CGContext(data: nil,
                                width: Int(outputSize.width),
                                height: Int(outputSize.height),
                                bitsPerComponent: self.bitsPerComponent,
                                bytesPerRow: bitmapBytesPerRow,
                                space: self.colorSpace!,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(CGRect(x: CGFloat.zero,
                             y: CGFloat.zero,
                             width: outputSize.width,
                             height: outputSize.height))
        
        var uiCoords = CGAffineTransform(scaleX: outputSize.width / cropSize.width,
                                         y: outputSize.height / cropSize.height)
        uiCoords = uiCoords.translatedBy(x: cropSize.width.half, y: cropSize.height.half)
        uiCoords = uiCoords.scaledBy(x: 1.0, y: -1.0)
        
        context?.concatenate(uiCoords)
        context?.concatenate(transform)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.draw(self, in: CGRect(x: (-imageViewSize.width.half),
                                       y: (-imageViewSize.height.half),
                                       width: imageViewSize.width,
                                       height: imageViewSize.height))
        
        let result = context!.makeImage()!
        
        return result
    }
}

// MARK: - UIColor extension

extension UIColor {
    
    class func mask() -> UIColor {
        return UIColor(white: CGFloat.zero, alpha: 0.6)
    }
    
    class func cropLine() -> UIColor {
        return UIColor(white: 1.0, alpha: 1.0)
    }
    
    class func gridLine() -> UIColor {
        return UIColor(red: 0.52, green: 0.48, blue: 0.47, alpha: 0.8)
    }
    
    class func photoTweakCanvasBackground() -> UIColor {
        return UIColor(white: CGFloat.zero, alpha: 1.0)
    }
}


// MARK: - CGPoint extension

extension CGPoint {
    func distanceTo(point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - self.x, 2) + pow(point.y - self.y, 2))
    }
}


// MARK: - CGFloat extension

extension CGFloat {
    var half: CGFloat {
        return self / 2.0
    }
    
    var oneThird: CGFloat {
        return self / 3.0
    }
    
    static var zero: CGFloat {
        return 0.0
    }
}

// MARK: - CGSize extension

extension CGSize {
    func rounded() -> CGSize {
        return CGSize(width: self.width.rounded(), height: self.height.rounded())
    }
}

// MARK: - CGRect extension

extension CGRect {
    func rounded() -> CGRect {
        return CGRect(x: self.origin.x.rounded(), y: self.origin.y.rounded(), width: self.width.rounded(), height: self.height.rounded())
    }
}
