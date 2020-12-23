//
//  MultipleEditorVC.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/2/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

open class MultipleEditorVC: UIViewController {

    var layoutType: MediaMontageType!
    var images: [UIImage]! = [UIImage]()
    var vWidth: CGFloat! = 0
    var vHeight: CGFloat! = 0
    
    public weak var delegate: MultiEditorDelegate?
    
    let editview = UIView()
    let bottomview = UIView()
    let bottomToolbar = UIView()
    
    var editMode: EditMode = .rotate
    var editableViews = [LCEditableView]()
    var appliedFilter: LCFilterable!
    
    var orientations = UIInterfaceOrientationMask.portrait //or what orientation you want
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        get { return self.orientations }
        set { self.orientations = newValue }
    }
    
    lazy private var filterSubMenuView: LCFilterMenu? = {
        let availableFilters = kDefaultAvailableFilters
        let originImage = images.first
        let filterSubMenuView = LCFilterMenu(withImage: originImage!.resize(toSizeInPixel: CGSize(width: 90, height: 90)),
                                             appliedFilter: self.appliedFilter,
                                                  availableFilters: availableFilters)
        filterSubMenuView.didSelectFilter = { [unowned self] filter in
            self.appliedFilter = filter
            LCLoadingView.shared.show()
            DispatchQueue.global(qos: .utility).async {
                for editView in self.editableViews {
                    let output = filter.filter(image: editView.image!)
                    DispatchQueue.main.sync {
                        editView.scrollView.photoContentView.image = output
                    }
                }
                LCLoadingView.shared.hide()
            }
        }
        return filterSubMenuView
    }()
    
    lazy private var effectSubMenuView: LCEffectMenu? = {
        let availableEffectors = kDefaultEffectors
        let originImage = images.first
        let effectSubMenuView = LCEffectMenu(withImage: originImage!.resize(toSizeInPixel: CGSize(width: 90, height: 90)), availableFilters: availableEffectors)
        effectSubMenuView.didSelectEffector = { [unowned self] effector in
            LCLoadingView.shared.show()
            DispatchQueue.global(qos: .utility).async {
                for editView in self.editableViews {
                    let output = effector.effector(image: editView.image)
                    DispatchQueue.main.sync {
                        editView.scrollView.photoContentView.image = output
                    }
                }
                LCLoadingView.shared.hide()
            }
        }
        return effectSubMenuView
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemBackground
        vWidth = self.view.frame.size.width
        vHeight = self.view.frame.size.height
        
        setupBottomButtons()
        setupBottomToolbar()
        setupFilterMenubar()
        
        setupEditableImageViews()
    }
    
    func setupBottomButtons() {
        let bvframe = CGRect(x: kEditViewPadding, y: vHeight - kBottomPaddingHeight - kBottomButtonHeight, width: vWidth - kEditViewPadding * 2, height: kBottomButtonHeight)
        bottomview.frame = bvframe
        view.addSubview(bottomview)
        
        let buttonWidth = (bvframe.width - kEditViewPadding) / 2
        
        let backButton = CustomButton()
        backButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: kBottomButtonHeight)
        backButton.backgroundColor = .clear
        backButton.setTitleColor(kButtonTintColor, for: .normal)
        backButton.setTitle(TITLE_BACK, for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        bottomview.addSubview(backButton)
        
        let exportButton = CustomButton()
        exportButton.frame = CGRect(x: buttonWidth + kEditViewPadding, y: 0, width: buttonWidth, height: kBottomButtonHeight)
        exportButton.backgroundColor = kButtonTintColor
        exportButton.setTitle(TITLE_EXPORT, for: .normal)
        exportButton.addTarget(self, action: #selector(exportAction), for: .touchUpInside)
        bottomview.addSubview(exportButton)
        
    }
    
    func setupBottomToolbar() {
        let bvframe = CGRect(x: kEditViewPadding, y: bottomview.frame.origin.y - kEditViewPadding - kBottomButtonHeight, width: vWidth - kEditViewPadding * 2, height: kBottomButtonHeight)
        bottomToolbar.frame = bvframe
        view.addSubview(bottomToolbar)
        
        let segmentItems = [TITLE_FILTER, TITLE_ROTATE, TITLE_EFFECT]
        let control = LCSegmentedControl(items: segmentItems)
        control.frame = CGRect(x: 0, y: 0, width: (vWidth - kEditViewPadding * 2), height: kBottomButtonHeight)
        control.addTarget(self, action: #selector(editControl(_:)), for: .valueChanged)
        control.selectedSegmentIndex = 1
        bottomToolbar.addSubview(control)
    }
    
    func setupFilterMenubar() {
        let bvframe = CGRect(x: kEditViewPadding, y: bottomToolbar.frame.origin.y - kEditViewPadding - kFilterBarHeight, width: vWidth - kEditViewPadding * 2, height: kFilterBarHeight)
        filterSubMenuView?.frame = bvframe
        view.addSubview(filterSubMenuView!)
        
        effectSubMenuView?.frame = bvframe
        view.addSubview(effectSubMenuView!)
        
        filterSubMenuView?.isHidden = true
        effectSubMenuView?.isHidden = true
    }
    
    func setupEditableImageViews() {
        editableViews.removeAll()
        
        var yPosition = kNavBarHeight + kTopToolBarHeight + kEditViewPadding
        let eWidth = vWidth - kEditViewPadding * 2
        var eHeight = (filterSubMenuView?.frame.origin.y)! - yPosition
        
        var itemWidth = eWidth / 2
        var itemHeight = eHeight / 2
        var x: CGFloat = 0, y: CGFloat = 0
        
        if layoutType == .verticalTow || layoutType == .verticalThree {
            itemWidth = eWidth
        } else if layoutType == .horizontalThree || layoutType == .sixth {
            itemWidth = eWidth / 3
        }
        
        if layoutType == .verticalThree {
            itemHeight = eHeight / 3
        }
        
        if layoutType == .horizontalThree || layoutType == .horizontalTwo {
            yPosition = yPosition + itemHeight / 2
            eHeight = eHeight / 2
        }
    
        editview.frame = CGRect(x: kEditViewPadding, y: yPosition, width: eWidth, height: eHeight)
        self.view.addSubview(editview)
        
        for (index, image) in images.enumerated() {
            switch layoutType {
            case .verticalTow, .verticalThree:
                y = itemHeight * CGFloat(index)
            case .horizontalTwo, .horizontalThree:
                x = itemWidth * CGFloat(index)
            case .four:
                x = itemWidth * CGFloat(index % 2)
                y = itemHeight * CGFloat(Int(index / 2))
            case .sixth:
                x = itemWidth * CGFloat(index % 3)
                y = itemHeight * CGFloat(Int(index / 3))
            default:
                print("default case")
            }
            
            let frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
            let editableView = LCEditableView(frame: frame, image: image)
            editview.addSubview(editableView)
            editableViews.append(editableView)
        }
    }
    
    private func changeImages() {
        for editView in self.editableViews {
            editView.image = editView.scrollView.photoContentView.image
        }
    }
    
    @objc func exportAction() {
//        changeImages()
        LCLoadingView.shared.show()
        let exportImage = cropImages()
        DispatchQueue.global(qos: .utility).async {
            LCLoadingView.shared.hide()
        }
        
        self.delegate?.multiEditor(self, didFinishWithCroppedImage: exportImage)
    }
    
    @objc func backAction() {
        self.delegate?.multiEditorDidCancel(self)
    }

    @objc func editControl(_ segmentedControl: UISegmentedControl) {
//        syncImages()
        if segmentedControl.selectedSegmentIndex == 0 { //filter
//            changeImages()
            self.editMode = .filter
            filterSubMenuView?.isHidden = false
            effectSubMenuView?.isHidden = true
        } else if segmentedControl.selectedSegmentIndex == 1 { //preview & rotate
            self.editMode = .rotate
            filterSubMenuView?.isHidden = true
            effectSubMenuView?.isHidden = true
        } else { // effect
            self.editMode = .effect
            filterSubMenuView?.isHidden = true
            effectSubMenuView?.isHidden = false
        }
    }
    
    func syncImages() {
        for editView in self.editableViews {
            editView.image = editView.scrollView.photoContentView.image
        }
    }
    
    func getImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: editview.bounds)
        return renderer.image { rendererContext in
            editview.layer.render(in: rendererContext.cgContext)
        }
    }
    
    func cropImages() -> UIImage {
        var frameScale: CGFloat = 20
        var images = [UIImage]()
        
        for editView in editableViews {
            var transform = CGAffineTransform.identity
            // translate
            let translation: CGPoint = editView.photoTranslation
            transform = transform.translatedBy(x: translation.x, y: translation.y)
            // rotate
            transform = transform.rotated(by: editView.radians)
            
            // scale
            let t: CGAffineTransform = editView.photoContentView.transform
            let xScale: CGFloat = sqrt(t.a * t.a + t.c * t.c)
            let yScale: CGFloat = sqrt(t.b * t.b + t.d * t.d)
            transform = transform.scaledBy(x: xScale, y: yScale)
            
            if let fixedImage = editView.photoContentView.image.cgImageWithFixedOrientation() {
                var zoomScale = editView.scrollView.zoomScale
                if zoomScale > kMinimumZoomScale {
                    zoomScale = getImageZoomScale(zoomScale, cropSize: editView.frame.size, imageSize: editView.photoContentView.image.size)
                }
                
                let imageRef = fixedImage.transformedImage(transform,
                                                           zoomScale: zoomScale,
                                                           sourceSize: editView.photoContentView.image.size,
                                                           cropSize: editView.frame.size,
                                                           imageViewSize: editView.photoContentView.bounds.size)
                
                let image = UIImage(cgImage: imageRef)
                images.append(image)
                
                let fScale: CGFloat!
//                if zoomScale > kMinimumZoomScale {
//                    fScale = getOptimizedFrameScale(zoomScale, cropSize: editView.frame.size, imageSize: editView.photoContentView.image.size)
//                } else {
                    fScale = getImageScale(cropSize: editView.frame.size, imageSize: editView.photoContentView.image.size)
//                }
                
                if fScale < frameScale {
                    frameScale = fScale
                }
            } else {
                images.append(editView.photoContentView.image)
            }
        }
        
        let newImage = mergeImages(images, frameScale)
        return newImage
        
    }
    
    func mergeImages(_ images: [UIImage], _ scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: editview.frame.size.width * scale, height: editview.frame.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)//
        
        for (index, editView) in editableViews.enumerated() {
            print("mergeIndex=\(index)")
            let image = images[index]
            let frame = CGRect(x: editView.frame.origin.x * scale, y: editView.frame.origin.y * scale, width: editView.frame.size.width * scale, height: editView.frame.size.height * scale)
            image.draw(in: frame)
        }
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        print("New mergedImage's Size = \(newImage.size)")
        return newImage
    }    
    
}
