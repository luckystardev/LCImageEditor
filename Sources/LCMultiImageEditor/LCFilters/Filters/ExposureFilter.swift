//
//  ExposureFilter.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/16/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

extension CIImage {
    
    func ExposureFilter(_ value: Double) -> CIImage? {
        
        let filterName = "CIExposureAdjust"
        guard let filter = CIFilter(name: filterName) else {
            print("No filter with name: \(filterName).")
            return self
        }

        filter.setDefaults()
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.setValue(value, forKey: kCIInputEVKey)

        return filter.outputImage ?? self
    }
}
