//
//  LayoutType.swift
//  LCMultiImageEditorDefine
//
//  Created by LuckyClub on 12/1/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

public enum MediaMontageType {
    case verticalTow
    case horizontalTwo
    case verticalThree
    case horizontalThree
    case four
    case sixth
}

enum EditType {
    case single
    case multiple
}

enum EditMode {
    case crop
    case filter
    case effect
}

enum setupImagesMode {
    case new
    case reset
    case edit
}

let kPadding: CGFloat = 12.0
let kTopToolBarHeight: CGFloat = 30.0
let kBottomButtonHeight: CGFloat = 48.0
let kBottomToolBarHeight: CGFloat = 28.0
let kBottomToolBarWidth: CGFloat = 150.0

let kMainToolBarHeight: CGFloat = 110.0
let kCropToolBarWidth: CGFloat = 300.0
let kCropToolBarHeight: CGFloat = 30.0

// define Colors
let kBlueColor: UIColor = UIColor.systemBlue
let kGrayColor: UIColor = UIColor.systemGray
let kDarkTextColor: UIColor = UIColor.darkText
let kBlackColor: UIColor = UIColor.black

// define button titles
let TITLE_PREVIEW = "Preview"
let TITLE_EXPORT  = "Export"
let TITLE_ROTATE  = "Preview"
let TITLE_FILTER  = "Filter"
let TITLE_EFFECT  = "Effect"
let TITLE_CANCEL  = "Cancel"
let TITLE_COMPOSE = "Photo Compose"
