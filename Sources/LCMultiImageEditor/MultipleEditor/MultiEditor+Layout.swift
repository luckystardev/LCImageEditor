//
//  MultiEditor+Layout.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/29/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

enum MontageRatioType {
    case custom
    case nineSixteenth
    case threeFourth
    case fourThird
    case sixteenNinth
    case square
}

extension LCMultiImageEditor {
    func getSlotSize(_ frame: CGSize, layoutType: MediaMontageType, ratioType: MontageRatioType) -> CGSize {
        
        let slotAspectRatio = getCropAspectRatio(layoutType, ratioType: ratioType)
        let column = getColumns(layoutType)
        let row = getRows(layoutType)
        
        let frameRatio = frame.height / frame.width
        let slotRatio = (slotAspectRatio.height * row) / (slotAspectRatio.width * column)
        
        if frameRatio > slotRatio{
            let width = frame.width / column
            let height = width * slotAspectRatio.height / slotAspectRatio.width
            return CGSize(width: width, height: height)
        } else {
            let height = frame.height / row
            let width = height * slotAspectRatio.width / slotAspectRatio.height
            return CGSize(width: width, height: height)
        }
    }
    
    private func getColumns(_ layoutType: MediaMontageType) -> CGFloat {
        switch layoutType {
            case .verticalTow, .verticalThree:
                return 1
            case .horizontalTwo, .four:
                return 2
            default:
                return 3
        }
    }
    
    private func getRows(_ layoutType: MediaMontageType) -> CGFloat {
        switch layoutType {
            case .horizontalTwo, .horizontalThree:
                return 1
            case .verticalThree:
                return 3
            default:
                return 2
        }
    }
    
    private func getSlotAspectRatio(_ layoutType: MediaMontageType, ratioType: MontageRatioType) -> CGSize {
        switch ratioType {
            case .custom:
                if (layoutType == .verticalTow || layoutType == .verticalThree) {
                    return CGSize(width: 16, height: 9)
                }
                return CGSize(width: 9, height: 16)
            case .nineSixteenth:
//                if (layoutType == .verticalTow || layoutType == .verticalThree) {
//                    return CGSize(width: 16, height: 9)
//                }
                return CGSize(width: 9, height: 16)
            case .threeFourth:
//                if (layoutType == .verticalTow || layoutType == .verticalThree) {
//                    return CGSize(width: 4, height: 3)
//                }
                return CGSize(width: 3, height: 4)
            case .square:
                return CGSize(width: 1, height: 1)
            case .sixteenNinth:
                return CGSize(width: 16, height: 9)
            case .fourThird:
                return CGSize(width: 4, height: 3)
        }
    }
    
    private func getCropAspectRatio(_ layoutType: MediaMontageType, ratioType: MontageRatioType) -> CGSize {
        let size = getSlotAspectRatio(layoutType, ratioType: ratioType)
        if ratioType == .custom {
            return size
        } else {
            let column = getColumns(layoutType)
            let row = getRows(layoutType)
            let width = size.width  / column
            let height = size.height / row
            
            return CGSize(width: width, height: height)
        }
    }
    
}
