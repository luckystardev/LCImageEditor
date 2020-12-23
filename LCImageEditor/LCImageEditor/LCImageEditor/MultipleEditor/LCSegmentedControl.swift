//
//  LCSegmentedControl.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/12/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

class LCSegmentedControl: UISegmentedControl {
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.selectedSegmentTintColor = kButtonTintColor
        self.layer.borderColor = kButtonTintColor.cgColor
        self.layer.borderWidth = 1.0
        let selectedtitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.setTitleTextAttributes(selectedtitleTextAttributes, for: .selected)
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: kButtonTintColor]
        self.setTitleTextAttributes(titleTextAttributes, for: .normal)
    }

}
