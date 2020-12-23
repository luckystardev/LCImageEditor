//
//  LCImageView.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

public class LCImageView: UIView {
    
    public weak var lcImageViewDelegate: LCImageViewDelegate?
    
    private(set) lazy var cropView: LCCropView! = {
        
        let cropView = LCCropView(frame: self.scrollView.frame,
                                   cornerBorderWidth:self.cornerBorderWidth(),
                                   cornerBorderLength:self.cornerBorderLength(),
                                   cropLinesCount:self.cropLinesCount(),
                                   gridLinesCount:self.gridLinesCount())
        cropView.center = self.scrollView.center
        
        cropView.layer.borderColor = self.borderColor().cgColor
        cropView.layer.borderWidth = self.borderWidth()
        self.addSubview(cropView)
        
        return cropView
        }()
    
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
    
    //MARK: - Private VARs
    
    internal var radians: CGFloat       = CGFloat.zero
    fileprivate var photoContentOffset  = CGPoint.zero
    
    internal lazy var scrollView: LCImageScrollView! = {
        
        let maxBounds = self.maxBounds()
        self.originalSize = maxBounds.size
        
        let scrollView = LCImageScrollView(frame: maxBounds)
        scrollView.center = self.centerPoint
        scrollView.delegate = self
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(scrollView)
        
        return scrollView
        }()
    
    internal weak var image: UIImage!
    internal var originalSize = CGSize.zero
    
    internal var manualZoomed = false
    internal var manualMove   = false
    
    // masks
    internal var topMask:    LCCropMaskView!
    internal var leftMask:   LCCropMaskView!
    internal var bottomMask: LCCropMaskView!
    internal var rightMask:  LCCropMaskView!
    
    // constants
    fileprivate var maximumCanvasSize: CGSize!
    fileprivate var originalPoint: CGPoint!
    internal var centerPoint: CGPoint = .zero
    
    // MARK: - Life Cicle
    
    init(frame: CGRect, image: UIImage, customizationDelegate: LCImageViewDelegate!) {
        super.init(frame: frame)
        
        self.image = image
        
        self.lcImageViewDelegate = customizationDelegate
        
        setupScrollView()
        setupCropView()
        setupMasks()
        
        self.originalPoint = self.convert(self.scrollView.center, to: self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if !manualMove {
            self.originalSize = self.maxBounds().size
            self.scrollView.center = self.centerPoint
            
            self.cropView.center = self.scrollView.center
            self.scrollView.checkContentOffset()
        }
    }
    
    //MARK: - Public FUNCs
    
    public func resetView() {
        UIView.animate(withDuration: kAnimationDuration, animations: {() -> Void in
            self.radians = CGFloat.zero
            self.scrollView.transform = CGAffineTransform.identity
            self.scrollView.center = self.centerPoint
            self.scrollView.bounds = CGRect(x: CGFloat.zero,
                                            y: CGFloat.zero,
                                            width: self.originalSize.width,
                                            height: self.originalSize.height)
            self.scrollView.minimumZoomScale = 1.0
            self.scrollView.setZoomScale(1.0, animated: false)
            
            self.cropView.frame = self.scrollView.frame
            self.cropView.center = self.scrollView.center
        })
    }
    
    public func applyDeviceRotation() {
        self.resetView()
        
        self.scrollView.center = self.centerPoint
        self.scrollView.bounds = CGRect(x: CGFloat.zero,
                                        y: CGFloat.zero,
                                        width: self.originalSize.width,
                                        height: self.originalSize.height)
        
        self.cropView.frame = self.scrollView.frame
        self.cropView.center = self.scrollView.center
        
        // Update 'photoContent' frame and set the image.
        self.scrollView.photoContentView.frame = .init(x: .zero, y: .zero, width: self.cropView.frame.width, height: self.cropView.frame.height)
        self.scrollView.photoContentView.image = self.image
        
        updatePosition()
    }
    
    //MARK: - Private FUNCs
    
    fileprivate func maxBounds() -> CGRect {
        // scale the image
        let insets = canvasInsets()
        self.maximumCanvasSize = frame.inset(by: insets).size
        self.centerPoint = CGPoint(x: maximumCanvasSize.width.half + insets.left, y: maximumCanvasSize.height.half + insets.top)

        let scaleX: CGFloat = self.image.size.width / self.maximumCanvasSize.width
        let scaleY: CGFloat = self.image.size.height / self.maximumCanvasSize.height
        let scale: CGFloat = max(scaleX, scaleY)
        
        let bounds = CGRect(x: CGFloat.zero,
                            y: CGFloat.zero,
                            width: (self.image.size.width / scale),
                            height: (self.image.size.height / scale))
        
        return bounds
    }
    
    internal func updatePosition() {
        // position scroll view
        let width: CGFloat = abs(cos(self.radians)) * self.cropView.frame.size.width + abs(sin(self.radians)) * self.cropView.frame.size.height
        let height: CGFloat = abs(sin(self.radians)) * self.cropView.frame.size.width + abs(cos(self.radians)) * self.cropView.frame.size.height
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
        if !self.manualZoomed || shouldScale {
            let zoom = self.scrollView.zoomScaleToBound()
            self.scrollView.setZoomScale(zoom, animated: false)
            self.scrollView.minimumZoomScale = zoom
            self.manualZoomed = false
        }
        
        self.scrollView.checkContentOffset()
    }
}
