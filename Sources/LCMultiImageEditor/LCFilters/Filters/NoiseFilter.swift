//
//  NoiseFilter.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/26/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

enum CINoiseMode {
    case noise
    case sharpness
}

extension CIImage {
    
    func NoiseFilter(_ value: Double, _ mode: CINoiseMode) -> CIImage? {
        
        let filterName = "CINoiseReduction"
        guard let filter = CIFilter(name: filterName) else {
            print("No filter with name: \(filterName).")
            return self
        }

        filter.setDefaults()
        filter.setValue(self, forKey: kCIInputImageKey)
        
        if mode == .noise {
            filter.setValue(value, forKey: "inputNoiseLevel")
        } else if mode == .sharpness {
            filter.setValue(value, forKey: kCIInputSharpnessKey)
        }

        return filter.outputImage ?? self
    }
}
