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

extension UIImage {
    
    func BrightnessFilter(_ value: Double, _ mode: CIColorMode) -> UIImage? {
        let filterName = "CIColorControls"
        guard let filter = CIFilter(name: filterName) else {
            print("No filter with name: \(filterName).")
            return self
        }

        let context = CIContext(options: nil)
        
        let inputImage = CIImage(image: self)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        
        if mode == .brightness {
            filter.setValue(value, forKey: kCIInputBrightnessKey)
        } else if mode == .contrast {
            filter.setValue(value, forKey: kCIInputContrastKey)
        } else if mode == .saturation {
            filter.setValue(value, forKey: kCIInputSaturationKey)
        }

        if let output = filter.outputImage,
            let cgimg = context.createCGImage(output, from: output.extent) {
                return UIImage(cgImage: cgimg)
        }
        return self
    }
}
