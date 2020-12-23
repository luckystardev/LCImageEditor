//
//  LCCropViewDelegate.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

public protocol LCCropViewDelegate : class {
    /*
     Calls ones, when user start interaction with view
     */
    func cropViewDidStartCrop(_ cropView: LCCropView)
    
    /*
     Calls always, when user move touch around view
     */
    func cropViewDidMove(_ cropView: LCCropView)
    
    /*
     Calls ones, when user stop interaction with view
     */
    func cropViewDidStopCrop(_ cropView: LCCropView)
    
    /*
     Calls ones, when change a Crop frame
     */
    func cropViewInsideValidFrame(for point: CGPoint, from cropView: LCCropView) -> Bool
}
