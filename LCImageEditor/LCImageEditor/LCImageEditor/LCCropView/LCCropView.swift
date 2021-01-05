//
//  LCCropView.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

public class LCCropView: UIView {
    
    //MARK: - Public VARs
    
    /*
     The optional View Delegate.
     */
    
    weak var delegate: LCCropViewDelegate?
    
    //MARK: - Private VARs
    
    internal lazy var horizontalCropLines: [LCCropLine] = {
        var lines = self.setupHorisontalLines(count: self.cropLinesCount,
                                              className: LCCropLine.self)
        return lines as! [LCCropLine]
        }()
    
    internal lazy var verticalCropLines: [LCCropLine] = {
        var lines = self.setupVerticalLines(count: self.cropLinesCount,
                                            className: LCCropLine.self)
        return lines as! [LCCropLine]
        }()
    
    internal lazy var horizontalGridLines: [LCCropGridLine] = {
        var lines = self.setupHorisontalLines(count: self.gridLinesCount,
                                              className: LCCropGridLine.self)
        return lines as! [LCCropGridLine]
        }()
    internal lazy var verticalGridLines: [LCCropGridLine] = {
        var lines = self.setupVerticalLines(count: self.gridLinesCount,
                                            className: LCCropGridLine.self)
        return lines as! [LCCropGridLine]
        }()
    
    internal var cornerBorderLength      = kCropViewCornerLength
    internal var cornerBorderWidth       = kCropViewCornerWidth
    
    internal var cropLinesCount         = kCropLinesCount
    internal var gridLinesCount         = kGridLinesCount
    
    internal var isCropLinesDismissed: Bool  = true
    internal var isGridLinesDismissed: Bool  = true
    
    internal var isAspectRatioLocked: Bool = false
    internal var aspectRatioWidth: CGFloat = CGFloat.zero
    internal var aspectRatioHeight: CGFloat = CGFloat.zero
    
    // MARK: - Life Cicle
    
    init(frame: CGRect,
         cornerBorderWidth: CGFloat,
         cornerBorderLength: CGFloat,
         cropLinesCount: Int,
         gridLinesCount: Int) {
        super.init(frame: frame)
        
        self.cornerBorderLength = cornerBorderLength
        self.cornerBorderWidth = cornerBorderWidth
        
        self.cropLinesCount = cropLinesCount
        self.gridLinesCount = gridLinesCount
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    fileprivate func setup() {
        
        self.setupLines()
        
        let upperLeft = LCCropCornerView(cornerType: .upperLeft,
                                          lineWidth: cornerBorderWidth,
                                          lineLenght: cornerBorderLength)
        upperLeft.center = CGPoint(x: cornerBorderLength.half,
                                   y: cornerBorderLength.half)
        self.addSubview(upperLeft)
        
        let upperRight = LCCropCornerView(cornerType: .upperRight,
                                           lineWidth: cornerBorderWidth,
                                           lineLenght:cornerBorderLength)
        upperRight.center = CGPoint(x: (self.frame.size.width - cornerBorderLength.half),
                                    y: cornerBorderLength.half)
        self.addSubview(upperRight)
        
        let lowerRight = LCCropCornerView(cornerType: .lowerRight,
                                           lineWidth: cornerBorderWidth,
                                           lineLenght:cornerBorderLength)
        lowerRight.center = CGPoint(x: (self.frame.size.width - cornerBorderLength.half),
                                    y: (self.frame.size.height - cornerBorderLength.half))
        self.addSubview(lowerRight)
        
        let lowerLeft = LCCropCornerView(cornerType: .lowerLeft,
                                          lineWidth: cornerBorderWidth,
                                          lineLenght:cornerBorderLength)
        lowerLeft.center = CGPoint(x: cornerBorderLength.half,
                                   y: (self.frame.size.height - cornerBorderLength.half))
        self.addSubview(lowerLeft)
        
        resetAspectRect()
    }
}

