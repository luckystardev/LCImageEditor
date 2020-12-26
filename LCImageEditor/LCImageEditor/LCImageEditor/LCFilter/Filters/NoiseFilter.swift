//
//  NoiseFilter.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/26/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

class NoiseFilter: NSObject {
    
}

enum CINoiseMode {
    case noise
    case sharpness
}

extension UIImage {
    
    func NoiseFilter(_ value: Double, _ mode: CINoiseMode) -> UIImage? {
        let filterName = "CINoiseReduction"
        guard let filter = CIFilter(name: filterName) else {
            print("No filter with name: \(filterName).")
            return self
        }

        let context = CIContext(options: nil)
        
        let inputImage = CIImage(image: self)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        
        if mode == .noise {
            filter.setValue(value, forKey: "inputNoiseLevel") //kCIInputNoiseLevelKey
        } else if mode == .sharpness {
            filter.setValue(value, forKey: kCIInputSharpnessKey)
        }

        if let output = filter.outputImage,
            let cgimg = context.createCGImage(output, from: output.extent) {
                return UIImage(cgImage: cgimg)
        }
        return self
    }
}
