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
}
