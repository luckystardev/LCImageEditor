//
//  LCMultiImageEditorDelegate.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/7/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

public protocol MultiEditorDelegate : class {
    
    func multiEditor(_ controller: LCMultiImageEditor, didFinishWithCroppedImage exportedImage: UIImage)

    func multiEditorDidCancel(_ controller: LCMultiImageEditor)
}
