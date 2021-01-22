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

extension CIImage {
    
    func HighlightFilter(_ value: Double, _ mode: CIHighlightMode) -> CIImage? {
        
        let filterName = "CIHighlightShadowAdjust"
        guard let filter = CIFilter(name: filterName) else {
            print("No filter with name: \(filterName).")
            return self
        }

        filter.setDefaults()
        filter.setValue(self, forKey: kCIInputImageKey)
        
        if mode == .highlight {
            filter.setValue(value, forKey: "inputHighlightAmount")
        } else if mode == .shadow {
            filter.setValue(value, forKey: "inputShadowAmount")
        }

        return filter.outputImage ?? self
    }
}
