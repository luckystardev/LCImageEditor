//
//  LCImageEditor+Custom.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import Foundation
import UIKit

extension LCImageEditor : LCImageViewDelegate {
    public func borderColor() -> UIColor {
        return self.customBorderColor()
    }
    
    public func borderWidth() -> CGFloat {
        return self.customBorderWidth()
    }
    
    public func cornerBorderWidth() -> CGFloat {
        return self.customCornerBorderWidth()
    }
    
    public func cornerBorderLength() -> CGFloat {
        return self.customCornerBorderLength()
    }
    
    public func cropLinesCount() -> Int {
        return self.customCropLinesCount()
    }
    
    public func gridLinesCount() -> Int {
        return self.customGridLinesCount()
    }
    
    public func isHighlightMask() -> Bool {
        return self.customIsHighlightMask()
    }
    
    public func highlightMaskAlphaValue() -> CGFloat {
        return self.customHighlightMaskAlphaValue()
    }
    
    public func canvasInsets() -> UIEdgeInsets {
        return self.customCanvasInsets()
    }
}
