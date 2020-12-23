//
//  BrightnessFilter.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/18/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

extension UIImage {
    
    func BrightnessFilter(_ value: Double) -> UIImage? {
        let filterName = "CIColorControls"
        guard let filter = CIFilter(name: filterName) else {
            print("No filter with name: \(filterName).")
            return self
        }

        let context = CIContext(options: nil)
        
        let inputImage = CIImage(image: self)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(value, forKey: kCIInputBrightnessKey)
//        filter.setValue(value, forKey: kCIInputContrastKey)

        if let output = filter.outputImage,
            let cgimg = context.createCGImage(output, from: output.extent) {
                return UIImage(cgImage: cgimg)
        }
        return self
    }
}
