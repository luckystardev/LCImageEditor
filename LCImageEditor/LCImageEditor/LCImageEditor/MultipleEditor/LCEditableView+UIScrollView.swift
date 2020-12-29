//
//  LCEditableView+UIScrollView.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/4/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

extension LCEditableView {
    
    internal func setupScrollView() {
        self.scrollView.updateDelegate = self
        
        self.photoContentView.image = image
        self.scrollView.photoContentView = self.photoContentView
    }
    
    public func changeAngle(radians: CGFloat) {
        // rotate scroll view
        self.radians = radians
        self.scrollView.transform = CGAffineTransform(rotationAngle: self.radians)
        
        self.updatePosition()
    }
}

extension LCEditableView : UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.photoContentView
    }
    
//    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
//        print("scrollViewWillBeginZooming")
//    }
//
//    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//        print("scrollViewDidEndZooming")
//    }
}

extension LCEditableView : LCImageScrollViewDelegate {
    public func scrollViewDidStartUpdateScrollContentOffset(_ scrollView: LCImageScrollView) {
        // TODO later
    }

    public func scrollViewDidStopScrollUpdateContentOffset(_ scrollView: LCImageScrollView) {
        // TODO later
    }
    
    public func rotateScrollView(_ scrollView: LCImageScrollView, _ radian: CGFloat) {
        self.changeAngle(radians: radian)
    }
}
