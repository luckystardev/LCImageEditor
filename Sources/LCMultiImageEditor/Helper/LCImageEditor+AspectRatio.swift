//
//  LCImageEditor+AspectRatio.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import Foundation

extension LCImageEditor {
    public func resetAspectRect() {
        self.photoView.resetAspectRect()
    }
    
    public func setCropAspectRect(aspect: String) {
        self.photoView.setCropAspectRect(aspect: aspect)
    }
    
    public func lockAspectRatio(_ lock: Bool) {
        self.photoView.lockAspectRatio(lock)
    }
    
}
