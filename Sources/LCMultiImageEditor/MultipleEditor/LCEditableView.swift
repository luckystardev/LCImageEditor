//
//  LCEditableView.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/5/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

class LCEditableView: UIView {
    
    var image: UIImage!
    var ciImage: CIImage! = nil
    weak var delegate : LCEditableViewDelegate?
    
    init(frame: CGRect, image: UIImage) {
        super.init(frame: frame)
        self.layer.masksToBounds = true
        
        self.image = image
        setupScrollView()
        self.applyDeviceRotation()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(taphandle(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tap)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func taphandle(_ sender: UITapGestureRecognizer) {
        self.delegate?.tapAction(self)
    }
    
    public func lock(_ isLock: Bool) {
        if isLock {
            //lock move, zoom, rotate
            self.scrollView.isUserInteractionEnabled = false
            self.scrollView.isScrollEnabled = false
        } else {
            self.scrollView.isUserInteractionEnabled = true
            self.scrollView.isScrollEnabled = true
        }
    }
    
    public func select(_ isSelect: Bool) {
        if isSelect {
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.red.cgColor
        } else {
            self.layer.borderWidth = 0
        }
    }
    
    public func resetFrame(_ frame: CGRect) {
        //init frame
        self.frame = frame
        
        //scrollView
        let maxBounds = self.maxBounds()
        self.originalSize = maxBounds.size
        self.centerPoint = CGPoint(x: maxBounds.width.half, y: maxBounds.height.half)
        
        self.scrollView.frame = maxBounds
        self.scrollView.center = self.centerPoint
        self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.size.width, height: self.scrollView.bounds.size.height)
        
        //photoContentView
        photoContentView.frame = self.scrollView.bounds
        
        //applyDeviceRotation
        self.resetView()
        let scaleX: CGFloat = self.image.size.width / self.frame.width
        let scaleY: CGFloat = self.image.size.height / self.frame.height
        let scale: CGFloat = min(scaleX, scaleY)

        self.scrollView.photoContentView.frame = .init(x: .zero, y: .zero, width: (self.image.size.width / scale), height: (self.image.size.height / scale))

        updatePosition()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if !manualMove {
            self.originalSize = self.maxBounds().size
            self.scrollView.center = self.centerPoint
            self.scrollView.checkContentOffset()
        }
    }
    
    public private(set) lazy var photoContentView: LCImageContentView! = {
        let photoContentView = LCImageContentView(frame: self.scrollView.bounds)
        photoContentView.isUserInteractionEnabled = true
        self.scrollView.addSubview(photoContentView)
        
        return photoContentView
        }()
        
    public var photoTranslation: CGPoint {
        get {
            let rect: CGRect = self.photoContentView.convert(self.photoContentView.bounds,
                                                             to: self)
            let point = CGPoint(x: (rect.origin.x + rect.size.width.half),
                                y: (rect.origin.y + rect.size.height.half))
            let zeroPoint = self.centerPoint
            
            return CGPoint(x: (point.x - zeroPoint.x), y: (point.y - zeroPoint.y))
        }
    }
    
    internal lazy var scrollView: LCImageScrollView! = {
        let maxBounds = self.maxBounds()
        self.originalSize = maxBounds.size
        self.centerPoint = CGPoint(x: maxBounds.width.half, y: maxBounds.height.half)
        
        let scrollView = LCImageScrollView(frame: maxBounds)
        scrollView.center = self.centerPoint
        scrollView.delegate = self
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(scrollView)
        
        return scrollView
        }()
        
    public var maximumZoomScale: CGFloat {
        set {
            self.scrollView.maximumZoomScale = newValue
        }
        get {
            return self.scrollView.maximumZoomScale
        }
    }
    
    public var minimumZoomScale: CGFloat {
        set {
            self.scrollView.minimumZoomScale = newValue
        }
        get {
            return self.scrollView.minimumZoomScale
        }
    }
    
    internal var radians: CGFloat       = CGFloat.zero
    fileprivate var photoContentOffset  = CGPoint.zero
    
    fileprivate var maximumCanvasSize: CGSize!
    internal var centerPoint: CGPoint = .zero
    internal var originalSize = CGSize.zero
    internal var manualMove   = false
    
    fileprivate func maxBounds() -> CGRect {
        // scale the image
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.maximumCanvasSize = frame.inset(by: insets).size
        self.centerPoint = CGPoint(x: maximumCanvasSize.width.half + insets.left, y: maximumCanvasSize.height.half + insets.top)
        
        let scaleX: CGFloat = self.image.size.width / self.frame.width
        let scaleY: CGFloat = self.image.size.height / self.frame.height
        let scale: CGFloat = min(scaleX, scaleY)
        
        let bounds = CGRect(x: CGFloat.zero,
                            y: CGFloat.zero,
                            width: (self.image.size.width / scale),
                            height: (self.image.size.height / scale))
        
        return bounds
    }
    
    public func resetView() {
        UIView.animate(withDuration: kAnimationDuration, animations: {() -> Void in
            self.radians = CGFloat.zero
            self.scrollView.transform = CGAffineTransform.identity
            self.scrollView.center = self.centerPoint
            self.scrollView.bounds = CGRect(x: CGFloat.zero,
                                            y: CGFloat.zero,
                                            width: self.originalSize.width,
                                            height: self.originalSize.height)
            self.scrollView.minimumZoomScale = kMinimumZoomScale
            self.scrollView.setZoomScale(1.0, animated: false)
            
        })
    }
    
    public func applyDeviceRotation() {
        self.resetView()
        
        self.scrollView.center = self.centerPoint
        self.scrollView.bounds = CGRect(x: CGFloat.zero,
                                        y: CGFloat.zero,
                                        width: self.originalSize.width,
                                        height: self.originalSize.height)
        
        // Update 'photoContent' frame and set the image.
        let scaleX: CGFloat = self.image.size.width / self.frame.width
        let scaleY: CGFloat = self.image.size.height / self.frame.height
        let scale: CGFloat = min(scaleX, scaleY)
        
        self.scrollView.photoContentView.frame = .init(x: .zero, y: .zero, width: (self.image.size.width / scale), height: (self.image.size.height / scale))
        self.scrollView.photoContentView.image = self.image
        
        updatePosition()
    }
        
    internal func updatePosition() {
        // position scroll view
        let width: CGFloat = abs(cos(self.radians)) * self.frame.size.width + abs(sin(self.radians)) * self.frame.size.height
        let height: CGFloat = abs(sin(self.radians)) * self.frame.size.width + abs(cos(self.radians)) * self.frame.size.height
        let center: CGPoint = self.scrollView.center
        let contentOffset: CGPoint = self.scrollView.contentOffset
        let contentOffsetCenter = CGPoint(x: (contentOffset.x + self.scrollView.bounds.size.width.half),
                                          y: (contentOffset.y + self.scrollView.bounds.size.height.half))
        self.scrollView.bounds = CGRect(x: CGFloat.zero, y: CGFloat.zero, width: width, height: height)
        let newContentOffset = CGPoint(x: (contentOffsetCenter.x - self.scrollView.bounds.size.width.half),
                                       y: (contentOffsetCenter.y - self.scrollView.bounds.size.height.half))
        self.scrollView.contentOffset = newContentOffset
        self.scrollView.center = center
        
        // scale scroll view
        let shouldScale: Bool = self.scrollView.contentSize.width / self.scrollView.bounds.size.width <= 1.0 ||
            self.scrollView.contentSize.height / self.scrollView.bounds.size.height <= 1.0
        if shouldScale {
           let zoom = self.scrollView.zoomScaleToBound()
           self.scrollView.setZoomScale(zoom, animated: false)
           self.scrollView.minimumZoomScale = zoom
       }
        self.scrollView.checkContentOffset()
    }
}

protocol LCEditableViewDelegate: NSObjectProtocol {
    func tapAction(_ editableview: LCEditableView)
}
