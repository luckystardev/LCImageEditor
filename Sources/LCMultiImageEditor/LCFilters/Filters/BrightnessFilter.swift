//
//  BrightnessFilter.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/18/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

enum CIColorMode {
    case brightness
    case contrast
    case saturation
}

extension CIImage {
    
    func BrightnessFilter(_ value: Double, _ mode: CIColorMode) -> CIImage? {
        
        let filterName = "CIColorControls"
        
        guard let filter = CIFilter(name: filterName) else {
            print("No filter with name: \(filterName).")
            return self
        }
        
        filter.setDefaults()
        filter.setValue(self, forKey: kCIInputImageKey)
        
        if mode == .brightness {
            let newValue = value * 0.2
            filter.setValue(newValue, forKey: kCIInputBrightnessKey)
        } else if mode == .contrast {
            var newValue: Double = 1.0
            if value < 0 {
                newValue = value * 0.5 + 1.0
            } else if value > 0 {
                newValue = value * 0.2 + 1.0
            }
            filter.setValue(newValue, forKey: kCIInputContrastKey)
        } else if mode == .saturation {
            let newValue = value + 1.0
            filter.setValue(newValue, forKey: kCIInputSaturationKey)
        }

        return filter.outputImage ?? self
    }
}
