//
//  MultiEditorExtensions.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/17/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

extension LCMultiImageEditor {
    func getImageScale(cropSize: CGSize, imageSize: CGSize) -> CGFloat {
        let scaleX: CGFloat = imageSize.width / cropSize.width
        let scaleY: CGFloat = imageSize.height / cropSize.height
        let scale: CGFloat = min(scaleX, scaleY)
        
        return scale
    }
    
    func getImageZoomScale(_ scrollZoom: CGFloat, cropSize: CGSize, imageSize: CGSize) -> CGFloat {
        let scale = getImageScale(cropSize: cropSize, imageSize: imageSize)
        let newScale = max(scrollZoom / scale, kMinimumZoomScale)
        
        return newScale
    }
    
    func getOptimizedFrameScale(_ scrollZoom: CGFloat, cropSize: CGSize, imageSize: CGSize) -> CGFloat {
        let newFrameScaleX = imageSize.width  * imageSize.width / cropSize.width * cropSize.width / scrollZoom
        let newFrameScaleY = imageSize.height  * imageSize.height / cropSize.height * cropSize.height / scrollZoom
        let scale: CGFloat = min(newFrameScaleX, newFrameScaleY)
        
        return scale
    }
    
    func getExpectScale(_ size: CGSize, scale: CGFloat) -> [CGFloat] {
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        var sizeHd = CGSize(width: 1980, height: 1080)
        if size.height / size.width >= 1 {
            sizeHd = CGSize(width: 1080, height: 1980)
        }
        let scaleHd = getImageScale(cropSize: sizeHd, imageSize: newSize)
        
        if scaleHd <= 1 {
            return [scale]
        } else {
            var sizeFk = CGSize(width: 3840, height: 2160)
            if size.height / size.width >= 1 {
                sizeFk = CGSize(width: 2160, height: 3840)
            }
            let scaleFk = getImageScale(cropSize: sizeFk, imageSize: newSize)
            
            if scaleFk <= 1 {
                return [scale / scaleHd, scale]
            } else {
                return [scale / scaleHd, scale / scaleFk, scale]
            }
        }
    }
    
    //Not used- Old version
    /*
    func mergeImages(_ images: [UIImage], _ scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: editview.frame.size.width * scale, height: editview.frame.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        
        for (index, editView) in editableViews.enumerated() {
            print("mergeIndex=\(index)")
            let image = images[index]
            let frame = CGRect(x: editView.frame.origin.x * scale, y: editView.frame.origin.y * scale, width: editView.frame.size.width * scale, height: editView.frame.size.height * scale)
            image.draw(in: frame)
        }
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        print("New mergedImage's Size = \(newImage.size)")
        
        return newImage
    } */
}
