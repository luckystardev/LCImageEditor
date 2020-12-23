//
//  LCImageEditor+Radian.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import Foundation
import UIKit

extension LCImageEditor {
    public func changeAngle(radians: CGFloat) {
        self.photoView.changeAngle(radians: radians)
    }
    
    public func stopChangeAngle() {
        self.photoView.stopChangeAngle()
    }
}
