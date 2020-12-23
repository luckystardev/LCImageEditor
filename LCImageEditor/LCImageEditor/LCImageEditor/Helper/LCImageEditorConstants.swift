//
//  LCImageEditorConstants.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

enum CropCornerType : Int {
    case upperLeft
    case upperRight
    case lowerRight
    case lowerLeft
}

let kCropLinesCount: Int = 2
let kGridLinesCount: Int = 8
let kCropViewLineWidth: CGFloat         = 2.0
let kCropViewCornerWidth: CGFloat       = 2.0
let kCropViewCornerLength: CGFloat      = 22.0
let kCropViewHotArea: CGFloat           = 40.0

let kMaximumCanvasWidthRatio: CGFloat   = 0.9
let kMaximumCanvasHeightRatio: CGFloat  = 0.8
let kCanvasHeaderHeigth: CGFloat        = 100.0

let kAnimationDuration: TimeInterval    = 0.25

let kMinimumZoomScale: CGFloat = 1.0
let kMaximumZoomScale: CGFloat = 10.0
