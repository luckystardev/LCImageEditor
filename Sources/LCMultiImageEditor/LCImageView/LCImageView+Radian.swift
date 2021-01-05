//
//  LCImageView+Radian.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit
import Foundation

extension LCImageView {
    public func changeAngle(radians: CGFloat) {
        // update masks
        self.highlightMask(true, animate: false)
        
        // update grids
        self.cropView.updateGridLines(animate: false)
        
        // rotate scroll view
        self.radians = radians
        self.scrollView.transform = CGAffineTransform(rotationAngle: self.radians)
        
        self.updatePosition()
    }
    
    public func stopChangeAngle() {
        self.cropView.dismissGridLines()
        self.highlightMask(false, animate: false)
    }
}
