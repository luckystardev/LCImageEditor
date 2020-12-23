//
//  BlurEyeFilter.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/17/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit
import CoreImage
import Foundation
import Vision

public class BlueEyeFilter: CIFilter {
    
    @objc var inputImage: CIImage?

    @objc public override var outputImage: CIImage? {
        guard
            let image = inputImage else {
            return nil
        }
        return useVNDetectFace(image: image)
    }

    struct FaceObservation {
        let face:VNFaceObservation
        let eyesLandmarks:[FaceLandmark]
    }

    struct FaceLandmark {
        let region:VNFaceLandmarkRegion2D
        let path:CGPath
        let flippedPath:CGPath
        let isLeft:Bool
    }

    func useVNDetectFace(image:CIImage)->CIImage{

        do {

            let semaphore = DispatchSemaphore(value: 0)

            var resultRequest:VNRequest?

            let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: {request, error in
                resultRequest = request
                if let error = error{
                    print("VNDetectFaceLandmarksRequest error:\(error)")
                }
                semaphore.signal()
            })

            faceDetectionRequest.preferBackgroundProcessing = true

            let imageRequestHandler = VNImageRequestHandler(ciImage: image, options: [:])

            try imageRequestHandler.perform([faceDetectionRequest])

            semaphore.wait()

            guard let observations = resultRequest?.results as? [VNFaceObservation] else {

                return image
            }

            var faces = [FaceObservation]()
            observations.forEach({

                var landmarks: [FaceLandmark] = []

                if let leftEye = $0.landmarks?.leftEye{
                    let path = BlueEyeFilter.createPath(imageSize:image.extent.size, landmark: leftEye, flipped: false)
                    let flippedPath = BlueEyeFilter.createPath(imageSize:image.extent.size, landmark: leftEye, flipped: true)
                    landmarks.append(FaceLandmark(region: leftEye, path: path, flippedPath: flippedPath, isLeft:true))
                }
                if let rightEye = $0.landmarks?.rightEye{
                    let path = BlueEyeFilter.createPath(imageSize:image.extent.size, landmark: rightEye, flipped: false)
                    let flippedPath = BlueEyeFilter.createPath(imageSize:image.extent.size, landmark: rightEye, flipped: true)
                    landmarks.append(FaceLandmark(region: rightEye, path: path, flippedPath: flippedPath, isLeft:false))
                }

                if landmarks.isEmpty == false {
                    faces.append(FaceObservation(face: $0, eyesLandmarks: landmarks))
                }


            })

            if faces.isEmpty{

                return image
            }

            return apply(observations: faces) ?? image


        } catch {

            return image
        }

    }


    fileprivate class func createPath(imageSize:CGSize, landmark: VNFaceLandmarkRegion2D, flipped:Bool =  false) -> CGPath{

        let points:[CGPoint] = landmark.pointsInImage(imageSize: imageSize).map({

            if flipped {

                return CGPoint(x: $0.x, y: imageSize.height - $0.y)

            }else{
                return $0
            }

        })
        return pathForPoints(points)

    }

    fileprivate class func pathForPoints(_ points: [CGPoint]) -> CGPath {
        let path: UIBezierPath = UIBezierPath()

        for (index, point) in points.enumerated() {
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.close()

        return path.cgPath
    }



    fileprivate func apply(observations: [FaceObservation]) -> CIImage? {
        guard
            let image = inputImage else {
            return nil
        }

        if observations.isEmpty {
            return image
        }

        let radius = max(image.extent.size.width, image.extent.size.height) / 60
        let imageWithEffect = CIFilter(name: "CIDiscBlur", parameters:[kCIInputImageKey: image, kCIInputRadiusKey: radius])!.outputImage!



        var eyesRects = [CGRect]()

        observations.forEach({
            $0.eyesLandmarks.forEach({
                let box = $0.flippedPath.boundingBox
                let scaled = box.centerAndAdjustPercentage(wScale: 2.5, hScale: 3.5)
                eyesRects.append(scaled)
            })
        })


        let maskImage = self.drawRectsImage(size: image.extent.size, rects: eyesRects)

        let blendFilter = CIFilter(name: "CIBlendWithMask", parameters: [
            kCIInputImageKey: imageWithEffect,
            kCIInputBackgroundImageKey: image,
            kCIInputMaskImageKey: maskImage!
        ])!


        let finalImage = blendFilter.outputImage

        return finalImage

    }

    func drawRectsImage(size:CGSize, rects:[CGRect]) -> CIImage?{

        UIGraphicsBeginImageContext(size)

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.green.cgColor)

        for rect in rects {
            let ovalPath = UIBezierPath(ovalIn: rect)
            context?.saveGState()
            drawLinearGradient(inside: ovalPath, rect: rect, colors: [UIColor.green, UIColor.green, UIColor.green, UIColor.clear], locations:nil, context: context)
            context?.restoreGState()


        }
        let pronama = CIImage(image: UIGraphicsGetImageFromCurrentImageContext()!, options: nil)!
        UIGraphicsEndImageContext()
        return pronama
    }


    func drawLinearGradient(inside path:UIBezierPath, rect:CGRect, colors:[UIColor], locations:[CGFloat]?, context:CGContext?)
    {
        path.addClip()

        let cgColors = colors.map({ $0.cgColor })

        guard let gradient = CGGradient(colorsSpace: nil, colors: cgColors as CFArray, locations: nil)
            else { return }

        context?.drawRadialGradient(gradient, startCenter: CGPoint(x: rect.midX, y: rect.midY), startRadius: 0, endCenter: CGPoint(x: rect.midX, y: rect.midY), endRadius: rect.size.width/2, options:  [.drawsBeforeStartLocation, .drawsAfterEndLocation])

    }
}


extension CGRect {
    func centerAndAdjustPercentage(wScale: CGFloat, hScale:CGFloat) -> CGRect {
        let x = self.origin.x
        let y = self.origin.y
        let w = self.width
        let h = self.height

        let newW = w * wScale
        let newH = h * hScale
        let newX = (w - newW) / 2
        let newY = (h - newH) / 2

        return CGRect(x: x + newX, y: y + newY, width: newW, height: newH)
    }
}
