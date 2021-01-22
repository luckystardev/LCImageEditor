//
//  VibranceFilter.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/26/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

extension CIImage {
    
    func VibranceFilter(_ value: Double) -> CIImage? {
        
        let filterName = "CIVibrance"
        guard let filter = CIFilter(name: filterName) else {
            print("No filter with name: \(filterName).")
            return nil
        }

        filter.setDefaults()
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.setValue(value, forKey: kCIInputAmountKey)

        return filter.outputImage ?? self
    }
}
