//
//  ChromaKeyFilter.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/17/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

extension CIImage {
    func convertToUIImage() -> UIImage
    {
        let uiImage = UIImage(ciImage: self)
        return uiImage
    }
}

// ChromaKeyFilter
extension UIImage {
    
    func ChromaKeyFilter() -> UIImage {
        // Remove Green from the Source Image
        let chromaCIFilter = self.applyChromaKeyFilter(fromHue: 0.5, toHue: 0.67)
        let ciImage = CIImage(image: self)
        chromaCIFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        let sourceCIImageWithoutBackground = chromaCIFilter?.outputImage
        var image = CIImage()
        if let filteredImage = sourceCIImageWithoutBackground {
            image = filteredImage
        }
        let uimage = image.convertToUIImage()
        return uimage
    }
    
    private func applyChromaKeyFilter(fromHue: CGFloat, toHue: CGFloat) -> CIFilter?
    {
        let size = 64
        var cubeRGB = [Float]()
            
        for z in 0 ..< size {
            let blue = CGFloat(z) / CGFloat(size-1)
            for y in 0 ..< size {
                let green = CGFloat(y) / CGFloat(size-1)
                for x in 0 ..< size {
                    let red = CGFloat(x) / CGFloat(size-1)
                        
                    let hue = getHue(red: red, green: green, blue: blue)
                    let alpha: CGFloat = (hue >= fromHue && hue <= toHue) ? 0: 1
                        
                    cubeRGB.append(Float(red * alpha))
                    cubeRGB.append(Float(green * alpha))
                    cubeRGB.append(Float(blue * alpha))
                    cubeRGB.append(Float(alpha))
                }
            }
        }

        let data = Data(buffer: UnsafeBufferPointer(start: &cubeRGB, count: cubeRGB.count))

        // 5
        let colorCubeFilter = CIFilter(name: "CIColorCube", parameters: ["inputCubeDimension": size, "inputCubeData": data])
        return colorCubeFilter
    }
    
    private func getHue(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat
    {
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        var hue: CGFloat = 0
        color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return hue
    }
}