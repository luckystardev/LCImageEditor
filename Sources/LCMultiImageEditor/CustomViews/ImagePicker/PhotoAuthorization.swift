//
//  PhotoAuthorization.swift
//  LCImageEditor
//
//  Created by LuckyClub on 1/13/21.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos

enum PhotoAuthorizedErrorType {
    case restricted
    case denied
}

enum PhotoAuthorizedResult {
    case success
    case error(PhotoAuthorizedErrorType)
}

typealias PhotoAuthorizedCompletion = ((PhotoAuthorizedResult) -> Void)

final class PhotoAuthorization {
    private init() {}
    
    static func media(mediaType: String, completion: PhotoAuthorizedCompletion?) {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: mediaType))
        switch status {
        case .authorized:
            completion?(PhotoAuthorizedResult.success)
        case .restricted:
            completion?(PhotoAuthorizedResult.error(.restricted))
        case .denied:
            completion?(PhotoAuthorizedResult.error(.denied))
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: mediaType)) { granted in
                DispatchQueue.main.async() {
                    if granted {
                        completion?(PhotoAuthorizedResult.success)
                    } else {
                        completion?(PhotoAuthorizedResult.error(.denied))
                    }
                }
            }
        @unknown default:
            print("default")
        }
    }
    
    static func camera(completion: PhotoAuthorizedCompletion?) {
        self.media(mediaType: AVMediaType.video.rawValue, completion: completion)
    }
    
    static func photo(completion: PhotoAuthorizedCompletion?) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            completion?(PhotoAuthorizedResult.success)
        case .restricted:
            completion?(PhotoAuthorizedResult.error(.restricted))
        case .denied:
            completion?(PhotoAuthorizedResult.error(.denied))
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization() { status in
                DispatchQueue.main.async() {
                    if status == PHAuthorizationStatus.authorized {
                        completion?(PhotoAuthorizedResult.success)
                    } else {
                        completion?(PhotoAuthorizedResult.error(.denied))
                    }
                }
            }
        @unknown default:
            print("default")
        }
    }
}
