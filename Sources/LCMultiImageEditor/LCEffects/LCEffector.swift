//
//  LCEffector.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/15/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

public protocol LCEffectable {
    func effector(image: UIImage, value: CGFloat) -> UIImage
    func effectorName() -> String
}

public enum LCEffector: LCEffectable {
    case EffectChromaKey
    case EffectBlurEye
        
    public func effector(image: UIImage, value: CGFloat) -> UIImage {
        switch self {
            case .EffectChromaKey:
                return image.ChromaKeyFilter(value)
            case .EffectBlurEye:
                let filter = BlueEyeFilter()
                filter.inputImage = CIImage(image: image)
                if let cimg = filter.outputImage {
                    let context = CIContext(options: nil)
                    return UIImage(cgImage: context.createCGImage(cimg, from: cimg.extent)!)
                }
                return image
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
