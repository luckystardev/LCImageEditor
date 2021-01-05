//
//  LCImageScrollView.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

@objc public protocol LCImageScrollViewDelegate : class{
    /*
     Calls ones, when user start interaction with view
     */
    func scrollViewDidStartUpdateScrollContentOffset(_ scrollView: LCImageScrollView)
    
    /*
     Calls ones, when user stop interaction with view
     */
    func scrollViewDidStopScrollUpdateContentOffset(_ scrollView: LCImageScrollView)
    
    @objc optional func rotateScrollView(_ scrollView: LCImageScrollView, _ radian: CGFloat)
}

public class LCImageScrollView: UIScrollView {
    
    //MARK: - Public VARs
    
    /*
     View for func viewForZooming(in scrollView: UIScrollView)
     */
    var photoContentView: LCImageContentView!
    
    /*
     The optional scroll delegate.
     */
    weak var updateDelegate: LCImageScrollViewDelegate?
    
    //MARK: - Protected VARs
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    fileprivate func setup() {
        self.bounces = true
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.alwaysBounceVertical = true
        self.alwaysBounceHorizontal = true
        self.minimumZoomScale = kMinimumZoomScale
        self.maximumZoomScale = kMaximumZoomScale
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.clipsToBounds = false
        self.contentSize = CGSize(width: self.bounds.size.width,
                                  height: self.bounds.size.height)
        
        let rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateGesture(_:)))
        addGestureRecognizer(rotateGestureRecognizer)
    }
    
    fileprivate var isUpdatingContentOffset = false
    
    //MARK: - Content Offsets
    
    public func checkContentOffset() {
        self.setContentOffsetX(max(self.contentOffset.x, 0))
        self.setContentOffsetY(max(self.contentOffset.y, 0))
        
        if self.contentSize.height - self.contentOffset.y <= self.bounds.size.height {
            self.setContentOffsetY(self.contentSize.height - self.bounds.size.height)
        }
        
        if self.contentSize.width - self.contentOffset.x <= self.bounds.size.width {
            self.setContentOffsetX(self.contentSize.width - self.bounds.size.width)
        }
    }
    
    public func setContentOffsetY(_ offsetY: CGFloat) {
        var contentOffset: CGPoint = self.contentOffset
        contentOffset.y = offsetY
        self.contentOffset = contentOffset
    }
    
    public func setContentOffsetX(_ offsetX: CGFloat) {
        var contentOffset: CGPoint = self.contentOffset
        contentOffset.x = offsetX
        self.contentOffset = contentOffset
    }
    
    override public var contentOffset: CGPoint {
        set {
            super.contentOffset = newValue
            
            if (!isUpdatingContentOffset) {
                isUpdatingContentOffset = true
                updateDelegate?.scrollViewDidStartUpdateScrollContentOffset(self)
            }
            
            let selector = #selector(self.stopUpdateContentOffset)
            LCImageScrollView.cancelPreviousPerformRequests(withTarget: self,
                                                             selector: selector,
                                                             object: nil)
            perform(selector, with: nil, afterDelay: kAnimationDuration * 2.0)
        }
        get {
            return super.contentOffset
        }
    }
    
    @objc func stopUpdateContentOffset() {
        if (isUpdatingContentOffset) {
            isUpdatingContentOffset = false
            updateDelegate?.scrollViewDidStopScrollUpdateContentOffset(self)
        }
    }
    
    public private(set) var rotation: CGFloat = 0
    
    @objc
    func rotateGesture(_ sender: UIRotationGestureRecognizer) {
        if sender.state == .began {
            
        } else if sender.state == .changed {
            rotation += sender.rotation
            updateDelegate?.rotateScrollView?(self, rotation)
//            transform = transform.rotated(by: sender.rotation)
        } else if sender.state == .ended {
            print("rotation = \(rotation)")
        }
        sender.rotation = 0
    }
    
    //MARK: - Zoom
    
    public func zoomScaleToBound() -> CGFloat {
        let scaleW: CGFloat = self.bounds.size.width / self.photoContentView.bounds.size.width
        let scaleH: CGFloat = self.bounds.size.height / self.photoContentView.bounds.size.height
        
        return max(scaleW, scaleH)
    }
}
