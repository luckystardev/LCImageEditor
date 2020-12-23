//
//  LCImageViewDelegate.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit
import Foundation

public protocol LCImageViewDelegate : class {
    /*
     Lines between mask and crop area
     */
    func borderColor() -> UIColor
    
    func borderWidth() -> CGFloat
    
    /*
     Corner of 2 border lines
     */
    func cornerBorderWidth() -> CGFloat
    
    func cornerBorderLength() -> CGFloat
    
    /*
     Lines Count
     */
    func cropLinesCount() -> Int
    
    func gridLinesCount() -> Int
    
    /*
     Mask customization
     */
    func isHighlightMask() -> Bool
    
    func highlightMaskAlphaValue() -> CGFloat
    
    /*
     Insets for crop view
     */
    func canvasInsets() -> UIEdgeInsets
}

extension LCImageView {
    
    func borderColor() -> UIColor {
        return (self.lcImageViewDelegate?.borderColor())!
    }
    
    func borderWidth() -> CGFloat {
        return (self.lcImageViewDelegate?.borderWidth())!
    }
    
    func cornerBorderWidth() -> CGFloat {
        return (self.lcImageViewDelegate?.cornerBorderWidth())!
    }
    
    func cornerBorderLength() -> CGFloat {
        return (self.lcImageViewDelegate?.cornerBorderLength())!
    }
    
    func cropLinesCount() -> Int {
        return (self.lcImageViewDelegate?.cropLinesCount())!
    }
    
    func gridLinesCount() -> Int {
        return (self.lcImageViewDelegate?.gridLinesCount())!
    }
    
    func isHighlightMask() -> Bool {
        return (self.lcImageViewDelegate?.isHighlightMask())!
    }
    
    func highlightMaskAlphaValue() -> CGFloat {
        return (self.lcImageViewDelegate?.highlightMaskAlphaValue())!
    }
    
    func canvasInsets() -> UIEdgeInsets {
        return (self.lcImageViewDelegate?.canvasInsets())!
    }
}
