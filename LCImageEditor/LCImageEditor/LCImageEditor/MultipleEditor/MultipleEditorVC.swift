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
    var editMode: EditMode = .rotate
    
    var images: [UIImage]! = [UIImage]() //image collage
    var vWidth: CGFloat! = 0 //self.view width
    var vHeight: CGFloat! = 0 //self.view height
    var sWidth: CGFloat! = 0 //workspace area's width
    
    public weak var delegate: MultiEditorDelegate?
    
    let topView = UIView()
    let editview = UIView()
    let bottomView = UIView()
    let bottomToolbar = UIView()
    let mainToolbar = UIView()
    
    var editableViews = [LCEditableView]()
    var appliedFilter: LCFilterable!
    
    var orientations = UIInterfaceOrientationMask.portrait
    
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
        filterSubMenuView.didSelectFilter = { [unowned self] (filter, value) in
            self.appliedFilter = filter
            LCLoadingView.shared.show()
            DispatchQueue.global(qos: .utility).async {
                for editView in self.editableViews {
                    let output = filter.filter(image: editView.scrollView.photoContentView.image!, value: value)
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
        
        initUI()
    }
    
    // MARK: - Initialize UI
    
    func initUI() {
        vWidth = self.view.frame.size.width
        vHeight = self.view.frame.size.height
        sWidth = vWidth - kPadding * 2
        
        setupTopView()
        setupBottomButtons()
        setupBottomToolbar()
        
        setupEditableImageViews()
    }
    
    func setupTopView() {
        topView.frame = CGRect(x: kPadding, y: kNavBarHeight, width: sWidth, height: kTopToolBarHeight)
        view.addSubview(topView)
        
        let titleLabel = UILabel(frame: CGRect(x: topView.center.x, y: 0, width: 200, height: kTopToolBarHeight))
        titleLabel.text = TITLE_COMPOSE
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        titleLabel.textAlignment = .center
        titleLabel.textColor = kTitleColor
        titleLabel.center.x = topView.center.x
        topView.addSubview(titleLabel)
        
        let cancelButton = UIButton(frame: CGRect(x: 8, y: 0, width: 60, height: kTopToolBarHeight))
        cancelButton.setTitle(TITLE_CANCEL, for: .normal)
        cancelButton.setTitleColor(kButtonTintColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        topView.addSubview(cancelButton)
        
        let resetButton = UIButton(frame: CGRect(x: sWidth - 36, y: (kTopToolBarHeight - 22).half, width: 28, height: 22))
        resetButton.setBackgroundImage(UIImage(systemName: "arrow.2.circlepath"), for: .normal)
        resetButton.tintColor = kButtonTintColor
        resetButton.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        topView.addSubview(resetButton)
    }
    
    func setupBottomButtons() {
        let bvframe = CGRect(x: kPadding, y: vHeight - kBottomSafeAreaHeight - kBottomButtonHeight, width: sWidth, height: kBottomButtonHeight)
        bottomView.frame = bvframe
        view.addSubview(bottomView)
        
        let buttonWidth = (bvframe.width - kPadding).half
        
        let previewButton = CustomButton()
        previewButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: kBottomButtonHeight)
        previewButton.backgroundColor = .clear
        previewButton.setTitleColor(kButtonTintColor, for: .normal)
        previewButton.setTitle(TITLE_PREVIEW, for: .normal)
        previewButton.addTarget(self, action: #selector(previewAction), for: .touchUpInside)
        bottomView.addSubview(previewButton)
        
        let exportButton = CustomButton()
        exportButton.frame = CGRect(x: buttonWidth + kPadding, y: 0, width: buttonWidth, height: kBottomButtonHeight)
        exportButton.backgroundColor = kButtonTintColor
        exportButton.setTitle(TITLE_EXPORT, for: .normal)
        exportButton.addTarget(self, action: #selector(exportAction), for: .touchUpInside)
        bottomView.addSubview(exportButton)
    }
    
    func setupBottomToolbar() {
        let bvframe = CGRect(x: kPadding, y: bottomView.frame.origin.y - kPadding - kBottomToolBarHeight, width: sWidth, height: kBottomToolBarHeight)
        bottomToolbar.frame = bvframe
        view.addSubview(bottomToolbar)
        
        let segment = LCSegment.init(frame: CGRect.init(x: (sWidth - kBottomToolBarWidth).half, y: 0, width: kBottomToolBarWidth, height: kBottomToolBarHeight))
        
        let itemAttribute0 = LCSegmentItemAttribute.config(tintColor: UIColor.systemGray, imageName: "dial", selectedTintColor: UIColor.systemBlue)
        let itemAttribute1 = LCSegmentItemAttribute.config(tintColor: UIColor.systemGray, imageName: "wand.and.stars", selectedTintColor: UIColor.systemBlue)
        let itemAttribute2 = LCSegmentItemAttribute.config(tintColor: UIColor.systemGray, imageName: "crop", selectedTintColor: UIColor.systemBlue)
        segment.config(dataSource: [itemAttribute0, itemAttribute1, itemAttribute2],
                        selectedIndex: 2) { (index) in
            self.editControl(index)
        }
        
        bottomToolbar.addSubview(segment)
        
        setupMainToolBar()
    }
    
    func setupMainToolBar() {
        let bvframe = CGRect(x: kPadding, y: bottomToolbar.frame.origin.y - kPadding - kMainToolBarHeight, width: sWidth, height: kMainToolBarHeight)
        mainToolbar.frame = bvframe
        view.addSubview(mainToolbar)
        
        setupFilterMenubar()
        
    }
    
    func setupFilterMenubar() {
        let bvframe = CGRect(x: 0, y: 0, width: sWidth, height: kMainToolBarHeight)
        filterSubMenuView?.frame = bvframe
        mainToolbar.addSubview(filterSubMenuView!)
        
        effectSubMenuView?.frame = bvframe
        mainToolbar.addSubview(effectSubMenuView!)
        
        filterSubMenuView?.isHidden = true
        effectSubMenuView?.isHidden = true
    }
    
    func setupEditableImageViews() {
        editableViews.removeAll()
        
        var yPosition = kNavBarHeight + kTopToolBarHeight + kPadding
        var eHeight = mainToolbar.frame.origin.y - yPosition
        
        var itemWidth = sWidth.half
        var itemHeight = eHeight.half
        var x: CGFloat = 0, y: CGFloat = 0
        
        if layoutType == .verticalTow || layoutType == .verticalThree {
            itemWidth = sWidth
        } else if layoutType == .horizontalThree || layoutType == .sixth {
            itemWidth = sWidth.oneThird
        }
        
        if layoutType == .verticalThree {
            itemHeight = eHeight.oneThird
        }
        
        if layoutType == .horizontalThree || layoutType == .horizontalTwo {
            yPosition = yPosition + itemHeight.half
            eHeight = eHeight.half
        }
    
        editview.frame = CGRect(x: kPadding, y: yPosition, width: sWidth, height: eHeight)
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
    
    // MARK: - Button Actions
    
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

    @objc func previewAction() {
        print("previewAction")
    }
    
    @objc func resetAction() {
        print("resetAction")
    }
    
    @objc func editControl(_ index: Int) {
        print("LCSegment current index:" + String(index))
//        syncImages()
        if index == 0 { // Correction filter
//            changeImages()
            self.editMode = .filter
            filterSubMenuView?.isHidden = false
            effectSubMenuView?.isHidden = true
        } else if index == 1 { // Filter
            self.editMode = .effect
            filterSubMenuView?.isHidden = true
            effectSubMenuView?.isHidden = false
        } else { // rotate & crop
            self.editMode = .rotate
            filterSubMenuView?.isHidden = true
            effectSubMenuView?.isHidden = true
        }
    }
    
    private func changeImages() {
        for editView in self.editableViews {
            editView.image = editView.scrollView.photoContentView.image
        }
    }
    
    func syncImages() {
        for editView in self.editableViews {
            editView.image = editView.scrollView.photoContentView.image
        }
    }
    
    // MARK: - Image Processing - Merge & Crop
    
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
            } else {
                images.append(editView.photoContentView.image)
            }
            
            let fScale: CGFloat!
            fScale = getImageScale(cropSize: editView.frame.size, imageSize: editView.photoContentView.image.size)
//            if zoomScale > kMinimumZoomScale {
//                fScale = getOptimizedFrameScale(zoomScale, cropSize: editView.frame.size, imageSize: editView.photoContentView.image.size)
//            } else {
//                fScale = getImageScale(cropSize: editView.frame.size, imageSize: editView.photoContentView.image.size)
//            }
            
            if fScale < frameScale {
                frameScale = fScale
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
