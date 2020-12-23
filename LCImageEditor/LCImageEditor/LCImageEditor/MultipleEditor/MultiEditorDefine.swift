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

let kEditViewPadding: CGFloat = 12.0
let kNavBarHeight: CGFloat = 44.0
let kBottomPaddingHeight: CGFloat = 34.0
let kTopToolBarHeight: CGFloat = 50.0
let kBottomButtonHeight: CGFloat = 50.0
let kFilterBarHeight: CGFloat = 64.0
let kBottomToolBarHeight: CGFloat = 180.0
let kButtonTintColor: UIColor = UIColor.systemBlue
let kEnteringAnimationDuration: Double = 0.225
let kLeavingAnimationDuration: Double = 0.175

// define button titles
let TITLE_BACK = "Back"
let TITLE_EXPORT = "Export"
let TITLE_ROTATE = "Preview"
let TITLE_FILTER = "Filter"
let TITLE_EFFECT = "Effect"
