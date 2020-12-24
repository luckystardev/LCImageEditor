//
//  LayoutType.swift
//  MultiEditorDefine
//
//  Created by LuckyClub on 12/1/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

enum MediaMontageType {
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
    case rotate
    case filter
    case effect
}

let kPadding: CGFloat = 12.0
let kNavBarHeight: CGFloat = 44.0
let kTopToolBarHeight: CGFloat = 30.0

let kBottomSafeAreaHeight: CGFloat = 34.0
let kBottomButtonHeight: CGFloat = 48.0

let kBottomToolBarHeight: CGFloat = 28.0
let kBottomToolBarWidth: CGFloat = 150.0

let kFilterBarHeight: CGFloat = 64.0

let kButtonTintColor: UIColor = UIColor.systemBlue
let kTitleColor: UIColor = UIColor.darkText

let kEnteringAnimationDuration: Double = 0.225
let kLeavingAnimationDuration: Double = 0.175

// define button titles
let TITLE_PREVIEW = "Preview"
let TITLE_EXPORT  = "Export"
let TITLE_ROTATE  = "Preview"
let TITLE_FILTER  = "Filter"
let TITLE_EFFECT  = "Effect"
let TITLE_CANCEL  = "Cancel"
let TITLE_COMPOSE = "Photo Compose"
