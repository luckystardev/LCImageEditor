//
//  ExposureFilter.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/16/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

extension UIImage {
    
    func ExposureFilter(_ value: Double) -> UIImage? {
        
        let filterName = "CIExposureAdjust"
        guard let filter = CIFilter(name: filterName) else {
            print("No filter with name: \(filterName).")
            return nil
        }

        let inputImage = CIImage(image: self)

        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(value, forKey: kCIInputEVKey)

        guard let filteredImage = filter.outputImage else {
            print("No output image.")
            return self
        }

        let context = CIContext(options: nil)
        return UIImage(cgImage: context.createCGImage(filteredImage, from: filteredImage.extent)!)
    }
}
