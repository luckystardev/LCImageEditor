//
//  LCCropCornerView.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

class LCCropCornerView: UIView {

    init(cornerType type: CropCornerType, lineWidth: CGFloat, lineLenght: CGFloat) {
        super.init(frame: CGRect(x: CGFloat.zero, y: CGFloat.zero, width: lineLenght, height: lineLenght))
        
        setup(cornerType: type,
              lineWidth: lineWidth,
              lineLenght:lineLenght)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup(cornerType: .upperRight,
              lineWidth: kCropViewLineWidth,
              lineLenght:kCropViewCornerLength)
    }
    
    fileprivate func setup(cornerType type: CropCornerType, lineWidth: CGFloat, lineLenght: CGFloat) {
        
        let horizontal = LCCropCornerLine(frame: CGRect(x: CGFloat.zero,
                                                         y: CGFloat.zero,
                                                         width: lineLenght,
                                                         height: lineWidth))
        self.addSubview(horizontal)
        
        let vertical = LCCropCornerLine(frame: CGRect(x: CGFloat.zero,
                                                       y: CGFloat.zero,
                                                       width: lineWidth,
                                                       height: lineLenght))
        self.addSubview(vertical)
        
        if type == .upperLeft {
            horizontal.center = CGPoint(x: lineLenght.half, y: lineWidth.half)
            vertical.center = CGPoint(x: lineWidth.half, y: lineLenght.half)
            self.autoresizingMask  = []
        }
        else if type == .upperRight {
            horizontal.center = CGPoint(x: lineLenght.half, y: lineWidth.half)
            vertical.center = CGPoint(x: lineLenght - lineWidth.half, y: lineLenght.half)
            self.autoresizingMask  = [.flexibleLeftMargin]
        }
        else if type == .lowerRight {
            horizontal.center = CGPoint(x: lineLenght.half, y: (lineLenght - lineWidth.half))
            vertical.center = CGPoint(x: lineLenght - lineWidth.half, y: (lineLenght.half))
            self.autoresizingMask  = [.flexibleTopMargin, .flexibleLeftMargin]
        }
        else if type == .lowerLeft {
            horizontal.center = CGPoint(x: lineLenght.half, y: (lineLenght - lineWidth.half))
            vertical.center = CGPoint(x: lineWidth.half, y: lineLenght.half)
            self.autoresizingMask  = [.flexibleTopMargin]
        }
    }

}
