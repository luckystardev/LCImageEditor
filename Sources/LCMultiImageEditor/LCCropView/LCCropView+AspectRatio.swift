//
//  LCCropView+AspectRatio.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import Foundation
import UIKit

extension LCCropView {
    
    public func resetAspectRect() {
        self.aspectRatioWidth = self.frame.size.width
        self.aspectRatioHeight = self.frame.size.height
    }
    
    public func setCropAspectRect(aspect: String, maxSize: CGSize) {
        let elements = aspect.components(separatedBy: ":")
        self.aspectRatioWidth = CGFloat(Float(elements.first!)!)
        self.aspectRatioHeight = CGFloat(Float(elements.last!)!)
        
        var size = maxSize
        let mW = size.width / self.aspectRatioWidth
        let mH = size.height / self.aspectRatioHeight
        
        if (mH < mW) {
            size.width = size.height / self.aspectRatioHeight * self.aspectRatioWidth
        }
        else if(mW < mH) {
            size.height = size.width / self.aspectRatioWidth * self.aspectRatioHeight
        }
        
        let x = (self.frame.size.width - size.width).half
        let y = (self.frame.size.height - size.height).half
        
        self.frame = CGRect(x:x, y:y, width: size.width, height: size.height)
    }
    
    public func lockAspectRatio(_ lock: Bool) {
        resetAspectRect()
        self.isAspectRatioLocked = lock
    }
}
