//
//  LCImageEditorDelegate.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

public protocol LCImageEditorDelegate : class {
    
    func lcImageEditor(_ controller: LCImageEditor, didFinishWithCroppedImage croppedImage: UIImage)

    func lcImageEditorDidCancel(_ controller: LCImageEditor)
}

