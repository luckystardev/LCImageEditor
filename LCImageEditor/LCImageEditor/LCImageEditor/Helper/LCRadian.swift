//
//  LCRadian.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit
import CoreGraphics

class LCRadian: NSObject {
    static public func toRadians(_ degrees: CGFloat) -> CGFloat {
        return (degrees * CGFloat.pi / 180.0)
    }
    
    static public func toDegrees(_ radians: CGFloat) -> CGFloat {
        return (radians * 180.0 / CGFloat.pi)
    }
}
