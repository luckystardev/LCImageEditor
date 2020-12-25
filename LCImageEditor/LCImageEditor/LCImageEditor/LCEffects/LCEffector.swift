//
//  LCEffector.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/15/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

public protocol LCEffectable {
    func effector(image: UIImage) -> UIImage
    func effectorName() -> String
}

public enum LCEffector: LCEffectable {
    case None
    case EffectBrightness
    case EffectExposure
    case EffectChromaKey
    case EffectBlurEye
        
    public func effector(image: UIImage) -> UIImage {
        switch self {
            case .None:
                return image
            case .EffectBrightness:
                return image.BrightnessFilter(0.5) ?? image
            case .EffectExposure:
                return image.ExposureFilter(0.5) ?? image
            case .EffectChromaKey:
                return image.ChromaKeyFilter()
            case .EffectBlurEye:
                let filter = BlueEyeFilter()
                filter.inputImage = CIImage(image: image)
                if let cimg = filter.outputImage {
                    let img = UIImage(ciImage: cimg)
                    return img
                }
                return image
        }
//        return image
    }
    
    public func effectorName() -> String {
        switch self {
            case .None: return "Original"
            case .EffectBrightness: return "Brightness"
            case .EffectExposure: return "Exposure"
            case .EffectChromaKey: return "Chroma"
            case .EffectBlurEye: return "Blur eye"
        }
    }
}

internal let kDefaultEffectors = [
    LCEffector.None,
//    LCEffector.EffectBrightness,
//    LCEffector.EffectExposure,
    LCEffector.EffectChromaKey,
    LCEffector.EffectBlurEye,
]
