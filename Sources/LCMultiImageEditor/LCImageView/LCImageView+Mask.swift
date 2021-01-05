//
//  LCImageView+Mask.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit
import Foundation

extension LCImageView {
    
    internal func setupMasks()
    {
        self.topMask = LCCropMaskView()
        self.addSubview(self.topMask)
        
        self.leftMask = LCCropMaskView()
        self.addSubview(self.leftMask)
        
        self.rightMask = LCCropMaskView()
        self.addSubview(self.rightMask)
        
        self.bottomMask = LCCropMaskView()
        self.addSubview(self.bottomMask)
        
        self.setupMaskLayoutConstraints()
    }
    
    internal func updateMasks() {
        self.layoutIfNeeded()
    }
    
    internal func highlightMask(_ highlight:Bool, animate: Bool) {
        if (self.isHighlightMask()) {
            let newAlphaValue: CGFloat = highlight ? self.highlightMaskAlphaValue() : 1.0
            
            let animationBlock: (() -> Void)? = {
                self.topMask.alpha = newAlphaValue
                self.leftMask.alpha = newAlphaValue
                self.bottomMask.alpha = newAlphaValue
                self.rightMask.alpha = newAlphaValue
            }
            
            if animate {
                UIView.animate(withDuration: kAnimationDuration, animations: animationBlock!)
            }
            else {
                animationBlock!()
            }
        }
    }
}
