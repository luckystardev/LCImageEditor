//
//  CustomButton.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/7/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = kButtonTintColor.cgColor
    }

}
