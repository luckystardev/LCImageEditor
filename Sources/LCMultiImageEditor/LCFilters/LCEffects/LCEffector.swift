//
//  LCEffector.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/15/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

public protocol LCEffectable {
    func apply(image: CIImage, value: CGFloat) -> CIImage
    func displayName() -> String
    func symbolImage() -> UIImage
}

public enum LCEffector: LCEffectable {
    case EffectChromaKey
    case EffectBlurEye
        
    public func apply(image: CIImage, value: CGFloat) -> CIImage {
        switch self {
            case .EffectChromaKey:
                return image.ChromaKeyFilter(value)
            case .EffectBlurEye:
                let filter = BlueEyeFilter()
                filter.inputImage = image
                guard let cimg = filter.outputImage else {
                    return image
                }
                return cimg
        }
    }
    
    public func displayName() -> String {
        switch self {
            case .EffectChromaKey: return "Chroma"
            case .EffectBlurEye: return "Blur eye"
        }
    }
    
    public func symbolImage() -> UIImage {
        var name: String = "photo"
        switch self {
            case .EffectChromaKey:
                name = "photo"
            case .EffectBlurEye:
                name = "eye.slash.fill"
        }
        return UIImage(systemName: name) ?? UIImage()
    }
}

internal let kDefaultEffectors = [
    LCEffector.EffectChromaKey,
    LCEffector.EffectBlurEye,
]
