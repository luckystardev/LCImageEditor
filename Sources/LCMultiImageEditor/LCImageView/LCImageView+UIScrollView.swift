//
//  LCImageView+UIScrollView.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit
import Foundation

extension LCImageView {
    
    internal func setupScrollView() {
        self.scrollView.updateDelegate = self
        
        self.photoContentView.image = image
        self.scrollView.photoContentView = self.photoContentView
    }
}

extension LCImageView : UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.photoContentView
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.cropView.updateCropLines(animate: true)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.manualZoomed = true
        self.cropView.dismissCropLines()
    }
}

extension LCImageView : LCImageScrollViewDelegate {
    public func scrollViewDidStartUpdateScrollContentOffset(_ scrollView: LCImageScrollView) {
        self.highlightMask(true, animate: true)
    }
    
    public func scrollViewDidStopScrollUpdateContentOffset(_ scrollView: LCImageScrollView) {
        self.updateMasks()
        self.highlightMask(false, animate: true)
    }
}

