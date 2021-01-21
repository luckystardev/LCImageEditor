//
//  LCEffector.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/15/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

public protocol LCEffectable {
    func effector(image: CIImage, value: CGFloat) -> CIImage
    func effectorName() -> String
}

public enum LCEffector: LCEffectable {
    case EffectChromaKey
    case EffectBlurEye
        
    public func effector(image: CIImage, value: CGFloat) -> CIImage {
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
    
    public func effectorName() -> String {
        switch self {
            case .EffectChromaKey: return "Chroma"
            case .EffectBlurEye: return "Blur eye"
        }
    }
}

internal let kDefaultEffectors = [
    LCEffector.EffectChromaKey,
    LCEffector.EffectBlurEye,
]
