//
//  LCFilter.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/11/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

public protocol LCFilterable {
    func apply(image: CIImage, value: Double) -> CIImage
    func filterName() -> String
    func symbolImage() -> UIImage
    func minimumValue() -> Double
    func valueChangeable() -> Bool
}

public enum LCFilter: LCFilterable {
    case None
    
    case CIEffectBrightness
    case CIEffectContrast
    case CIEffectSaturation
    case CIExposureAdjust
    case CIVibrance
    case CINoiseReduction
    case CISharpness
    case CIVignette
    case CIHighlight
    case CIShadow
    
    case CIBrilliance
    case CIBlackPoint
    case CITint
    case CIWarmth
    
    case CIPhotoEffectMono
    case CIPhotoEffectNoir
    
//    case CIPhotoEffectChrome
//    case CIPhotoEffectFade
//    case CIPhotoEffectInstant
//    case CIPhotoEffectProcess
//    case CIPhotoEffectTonal
//    case CIPhotoEffectTransfer
//    case CIColorCrossPolynomial
//    case CIColorCube
//    case CIColorCubeWithColorSpace
//    case CIColorInvert
//    case CIColorMonochrome
//    case CIColorPosterize
//    case CIFalseColor
//    case CIMinimumComponent
//    case CISepiaTone
    
    
    private func ciFilter() -> CIFilter? {
        var ciFilterName: String
        
        switch self {
            case .None: return nil
            
            case .CIEffectBrightness: ciFilterName = "CIEffectBrightness"
            case .CIEffectContrast: ciFilterName = "CIEffectContrast"
            case .CIEffectSaturation: ciFilterName = "CIEffectSaturation"
            case .CIExposureAdjust: ciFilterName = "CIExposureAdjust"
            case .CIVibrance: ciFilterName = "CIVibrance"
            case .CIVignette: ciFilterName = "CIVignette"
            case .CINoiseReduction: ciFilterName = "CINoiseReduction"
            case .CISharpness: ciFilterName = "CISharpness"
            case .CIHighlight: ciFilterName = "CIHighlight"
            case .CIShadow: ciFilterName = "CIShadow"
            
            case .CIBrilliance: ciFilterName = "CIBrilliance"
            case .CIBlackPoint: ciFilterName = "CIBlackPoint"
            case .CITint: ciFilterName = "CITint"
            case .CIWarmth: ciFilterName = "CIWarmth"
            
            case .CIPhotoEffectMono: ciFilterName = "CIPhotoEffectMono"
            case .CIPhotoEffectNoir: ciFilterName = "CIPhotoEffectNoir"
        }
        
        return CIFilter(name: ciFilterName)
    }
    
    public func apply(image: CIImage, value: Double) -> CIImage {
        
        let avalue = value / 100
        
        switch self {
            case .CIEffectBrightness:
                return image.BrightnessFilter(avalue, .brightness) ?? image
            case .CIEffectContrast:
                return image.BrightnessFilter(avalue, .contrast) ?? image
            case .CIEffectSaturation:
                return image.BrightnessFilter(avalue, .saturation) ?? image
            case .CIExposureAdjust:
                return image.ExposureFilter(avalue) ?? image
            case .CIVibrance:
                return image.VibranceFilter(avalue) ?? image
            case .CINoiseReduction:
                return image.NoiseFilter(avalue, .noise) ?? image
            case .CISharpness:
                return image.NoiseFilter(avalue, .sharpness) ?? image
            case .CIVignette:
                return image.VigentteFilter(avalue) ?? image
            case .CIHighlight:
                return image.HighlightFilter(avalue, .highlight) ?? image
            case .CIShadow:
                return image.HighlightFilter(avalue, .shadow) ?? image
            
            case .CIBrilliance: // TODO
                return image
            case .CIBlackPoint: // TODO
                return image
            case .CITint: // TODO
                return image
            case .CIWarmth: // TODO
                return image
            
            default:
                if let ciFilter = ciFilter() {
                    ciFilter.setDefaults()
                    ciFilter.setValue(image, forKey: kCIInputImageKey)
                    return ciFilter.outputImage ?? image
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
            case .CIExposureAdjust: return "Exposure"
            case .CIVibrance: return "Vibrance"
            case .CINoiseReduction: return "Noise"
            case .CISharpness: return "Sharpness"
            case .CIVignette: return "Vignette"
            case .CIHighlight: return "Highlight"
            case .CIShadow: return "Shadow"
            
            case .CIBrilliance: return "Brilliance"
            case .CIBlackPoint: return "Black Point"
            case .CITint: return "Tint"
            case .CIWarmth: return "Warmth"
            
            case .CIPhotoEffectMono: return "Mono"
            case .CIPhotoEffectNoir: return "Noir"
            
//            case .CIPhotoEffectChrome: return "Chrome"
//            case .CIPhotoEffectFade: return "Fade"
//            case .CIPhotoEffectInstant: return "Instant"
//            case .CIPhotoEffectProcess: return "Process"
//            case .CIPhotoEffectTonal: return "Tonal"
//            case .CIPhotoEffectTransfer: return "Transfer"
//            case .CIColorCrossPolynomial:return "Polynomial"
//            case .CIColorCube: return "Color Cube"
//            case .CIColorCubeWithColorSpace: return "Color Space"
//            case .CIColorInvert: return "Invert"
//            case .CIColorMonochrome: return "Monochrome"
//            case .CIColorPosterize: return "Posterize"
//            case .CIFalseColor: return "Color"
//            case .CIMinimumComponent: return "Component"
//            case .CISepiaTone: return "Sepia"
            
        }
    }
    
    public func symbolImage() -> UIImage {
        var name: String = "photo"
        switch self {
            case .CIEffectBrightness:
                name = "sun.min.fill"
            case .CIEffectContrast:
                name = "circle.righthalf.fill"
            case .CIEffectSaturation:
                name = "circle.lefthalf.fill"
            case .CIExposureAdjust:
                name = "plusminus.circle"
            case .CIHighlight:
                name = "bolt.circle"
            case .CIShadow:
                name = "icloud.circle"
            case .CIVibrance:
                name = "sparkles"
            case .CINoiseReduction:
                name = "light.min"
            case .CISharpness:
                name = "light.max"
            case .CIVignette:
                name = "viewfinder.circle"
            case .CIPhotoEffectMono:
                name = "moon.circle"
            case .CIPhotoEffectNoir:
                name = "moon.circle.fill"
            case .CIWarmth:
                name = "flame"
            case .CIBlackPoint:
                name = "smallcircle.fill.circle.fill"
            default:
                name = "photo"
        }
        return UIImage(systemName: name) ?? UIImage()
    }
    
    public func minimumValue() -> Double {
        switch self {
            case .CINoiseReduction: return 0
            case .CISharpness: return 0
            default: return -100.0
        }
    }
    
    public func valueChangeable() -> Bool {
        switch self {
            case .None: return false
            case .CIPhotoEffectMono: return false
            case .CIPhotoEffectNoir: return false
            default: return true
        }
    }
}

internal let kDefaultAvailableFilters = [
//    LCFilter.None,
    LCFilter.CIEffectBrightness,
    LCFilter.CIEffectContrast,
    LCFilter.CIEffectSaturation,
    LCFilter.CIExposureAdjust,
    LCFilter.CIHighlight,
    LCFilter.CIShadow,
    LCFilter.CIVibrance,
    LCFilter.CINoiseReduction,
    LCFilter.CISharpness,
    LCFilter.CIVignette,
    
//    LCFilter.CIBrilliance,
//    LCFilter.CIBlackPoint,
//    LCFilter.CITint,
//    LCFilter.CIWarmth,

    LCFilter.CIPhotoEffectMono,
    LCFilter.CIPhotoEffectNoir,
]
