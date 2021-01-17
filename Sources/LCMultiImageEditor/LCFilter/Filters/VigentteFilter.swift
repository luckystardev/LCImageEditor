//
//  VigentteFilter.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/26/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

extension CIImage {
    
    func VigentteFilter(_ value: Double) -> CIImage? {
        
        let filterName = "CIVignette"
        guard let filter = CIFilter(name: filterName) else {
            print("No filter with name: \(filterName).")
            return self
        }

        filter.setDefaults()
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.setValue(value, forKey: kCIInputIntensityKey)

        return filter.outputImage ?? self
    }
}
