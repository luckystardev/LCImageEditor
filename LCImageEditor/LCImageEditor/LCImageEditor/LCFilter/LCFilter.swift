//
//  LCFilter.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/11/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

public protocol LCFilterable {
    func filter(image: UIImage, value: Double) -> UIImage
    func filterName() -> String
    func minimumValue() -> Double
    func valueChangeable() -> Bool
}

public enum LCFilter: LCFilterable {
    case None
    
    case CIEffectBrightness
    case CIEffectContrast
    case CIEffectSaturation
    case CIEffectExposure
    
//    case CIPhotoEffectChrome
//    case CIPhotoEffectFade
//    case CIPhotoEffectInstant
//    case CIPhotoEffectMono
//    case CIPhotoEffectNoir
//    case CIPhotoEffectProcess
//    case CIPhotoEffectTonal
//    case CIPhotoEffectTransfer
//
//    case CIColorCrossPolynomial
//    case CIColorCube
//    case CIColorCubeWithColorSpace
//    case CIColorInvert
//    case CIColorMonochrome
//    case CIColorPosterize
//    case CIFalseColor
//    case CIMinimumComponent
//
//    case CISepiaTone
//    case CIVignette
    
    private func ciFilter() -> CIFilter? {
        var ciFilterName: String
        
        switch self {
            case .None: return nil
            
            case .CIEffectBrightness: ciFilterName = "CIEffectBrightness"
            case .CIEffectContrast: ciFilterName = "CIEffectContrast"
            case .CIEffectSaturation: ciFilterName = "CIEffectSaturation"
            case .CIEffectExposure: ciFilterName = "CIEffectExposure"
            
//            case .CIPhotoEffectChrome: ciFilterName = "CIPhotoEffectChrome"
//            case .CIPhotoEffectFade: ciFilterName = "CIPhotoEffectFade"
//            case .CIPhotoEffectInstant: ciFilterName = "CIPhotoEffectInstant"
//            case .CIPhotoEffectMono: ciFilterName = "CIPhotoEffectMono"
//            case .CIPhotoEffectNoir: ciFilterName = "CIPhotoEffectNoir"
//            case .CIPhotoEffectProcess: ciFilterName =  "CIPhotoEffectProcess"
//            case .CIPhotoEffectTonal: ciFilterName = "CIPhotoEffectTonal"
//            case .CIPhotoEffectTransfer: ciFilterName = "CIPhotoEffectTransfer"
//
//            case .CIColorCrossPolynomial: ciFilterName = "CIColorCrossPolynomial"
//            case .CIColorCube: ciFilterName = "CIColorCube"
//            case .CIColorCubeWithColorSpace: ciFilterName = "CIColorCubeWithColorSpace"
//            case .CIColorInvert: ciFilterName = "CIColorInvert"
//            case .CIColorMonochrome: ciFilterName = "CIColorMonochrome"
//            case .CIColorPosterize: ciFilterName = "CIColorPosterize"
//            case .CIFalseColor: ciFilterName = "CIFalseColor"
//            case .CIMinimumComponent: ciFilterName = "CIMinimumComponent"
//
//            case .CISepiaTone: ciFilterName = "CISepiaTone"
//            case .CIVignette: ciFilterName = "CIVignette"
        }
        
        return CIFilter(name: ciFilterName)
    }
    
    public func filter(image: UIImage, value: Double) -> UIImage {
        
        let avalue = value / 100
        
        switch self {
            case .CIEffectBrightness:
                return image.BrightnessFilter(avalue, .brightness) ?? image
            case .CIEffectContrast:
                return image.BrightnessFilter(avalue, .contrast) ?? image
            case .CIEffectSaturation:
                return image.BrightnessFilter(avalue, .saturation) ?? image
            case .CIEffectExposure:
                return image.ExposureFilter(avalue) ?? image
            default:
                if let ciFilter = ciFilter() {
                    let context = CIContext(options: nil)
                    
                    let beginImage = CIImage(image: image)
                    ciFilter.setValue(beginImage, forKey: kCIInputImageKey)
                    
                    if let output = ciFilter.outputImage,
                        let cgimg = context.createCGImage(output, from: output.extent) {
                            return UIImage(cgImage: cgimg,
                                           scale: image.scale,
                                           orientation: image.imageOrientation)
                    }
                    return UIImage()
                }
                
                return image
        }
    }
    
    public func filterName() -> String {
        switch self {
            case .None: return "Original"//"No Filter"//
            
            case .CIEffectBrightness: return "Brightness"
            case .CIEffectContrast: return "Contrast"
            case .CIEffectSaturation: return "Saturation"
            case .CIEffectExposure: return "Exposure"
            
//            case .CIPhotoEffectChrome: return "Chrome"
//            case .CIPhotoEffectFade: return "Fade"
//            case .CIPhotoEffectInstant: return "Instant"
//            case .CIPhotoEffectMono: return "Mono"
//            case .CIPhotoEffectNoir: return "Noir"
//            case .CIPhotoEffectProcess: return "Process"
//            case .CIPhotoEffectTonal: return "Tonal"
//            case .CIPhotoEffectTransfer: return "Transfer"
//
//            case .CIColorCrossPolynomial:return "Polynomial"
//            case .CIColorCube: return "Color Cube"
//            case .CIColorCubeWithColorSpace: return "Color Space"
//            case .CIColorInvert: return "Invert"
//
//            case .CIColorMonochrome: return "Monochrome"
//            case .CIColorPosterize: return "Posterize"
//            case .CIFalseColor: return "Color"
//            case .CIMinimumComponent: return "Component"
//
//            case .CISepiaTone: return "Sepia"
//            case .CIVignette: return "Vignette"
        }
    }
    
    public func minimumValue() -> Double {
        switch self {
            case .CIEffectContrast: return 0
            case .CIEffectSaturation: return 0
            
//            case .CIPhotoEffectChrome: return "Chrome"
//            case .CIPhotoEffectFade: return "Fade"
//            case .CIPhotoEffectInstant: return "Instant"
//            case .CIPhotoEffectMono: return "Mono"
//            case .CIPhotoEffectNoir: return "Noir"
//            case .CIPhotoEffectProcess: return "Process"
//            case .CIPhotoEffectTonal: return "Tonal"
//            case .CIPhotoEffectTransfer: return "Transfer"
//
//            case .CIColorCrossPolynomial:return "Polynomial"
//            case .CIColorCube: return "Color Cube"
//            case .CIColorCubeWithColorSpace: return "Color Space"
//            case .CIColorInvert: return "Invert"
//
//            case .CIColorMonochrome: return "Monochrome"
//            case .CIColorPosterize: return "Posterize"
//            case .CIFalseColor: return "Color"
//            case .CIMinimumComponent: return "Component"
//
//            case .CISepiaTone: return "Sepia"
//            case .CIVignette: return "Vignette"
            default: return -100.0
        }
    }
    
    public func valueChangeable() -> Bool {
        switch self {
            case .None: return false
            default: return true
        }
    }
}

internal let kDefaultAvailableFilters = [
    LCFilter.None,
    LCFilter.CIEffectBrightness,
    LCFilter.CIEffectContrast,
    LCFilter.CIEffectSaturation,
    LCFilter.CIEffectExposure,
    
//    LCFilter.CIPhotoEffectChrome,
//    LCFilter.CIPhotoEffectInstant,
//    LCFilter.CIPhotoEffectMono,
//    LCFilter.CIPhotoEffectProcess,
//    LCFilter.CIPhotoEffectTransfer,
//    LCFilter.CISepiaTone,
//    LCFilter.CIPhotoEffectNoir,
//    LCFilter.CIMinimumComponent,
//    LCFilter.CIColorPosterize,
//    LCFilter.CIColorMonochrome,
//    LCFilter.CIColorCrossPolynomial,
//    LCFilter.CIColorCube,
//    LCFilter.CIColorCubeWithColorSpace,
//    LCFilter.CIColorInvert,
//    LCFilter.CIFalseColor,
//    LCFilter.CIPhotoEffectFade,
//    LCFilter.CIPhotoEffectTonal,
//    LCFilter.CIVignette
]
