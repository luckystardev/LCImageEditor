//
//  HighlightFilter.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/26/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

enum CIHighlightMode {
    case highlight
    case shadow
}

extension UIImage {
    
    func HighlightFilter(_ value: Double, _ mode: CIHighlightMode) -> UIImage? {
        let filterName = "CIHighlightShadowAdjust"
        guard let filter = CIFilter(name: filterName) else {
            print("No filter with name: \(filterName).")
            return self
        }

        let context = CIContext(options: nil)
        
        let inputImage = CIImage(image: self)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        
        if mode == .highlight {
            filter.setValue(value, forKey: "inputHighlightAmount") //kCIInputNoiseLevelKey
        } else if mode == .shadow {
            filter.setValue(value, forKey: "inputShadowAmount")
        }

        if let output = filter.outputImage,
            let cgimg = context.createCGImage(output, from: output.extent) {
                return UIImage(cgImage: cgimg)
        }
        return self
    }
}
