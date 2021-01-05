//
//  LCMultiImageEditor.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/2/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

open class LCMultiImageEditor: UIViewController {

    var layoutType: MediaMontageType!
    var editMode: EditMode = .rotate
    var montageRatioType: MontageRatioType = .nineSixteenth
    
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
        let filterSubMenuView = LCFilterMenu(withImage: originImage!.resize(toSizeInPixel: CGSize(width: 64, height: 64)),
                                             appliedFilter: self.appliedFilter,
                                                  availableFilters: availableFilters)
        filterSubMenuView.didSelectFilter = { (filter, value) in
            self.appliedFilter = filter
            LCLoadingView.shared.show()
            DispatchQueue.global(qos: .utility).async {
                for editView in self.editableViews {
                    let output = filter.filter(image: editView.photoContentView.image!, value: value)
                    DispatchQueue.main.sync {
                        editView.photoContentView.image = output
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
        let effectSubMenuView = LCEffectMenu(withImage: originImage!.resize(toSizeInPixel: CGSize(width: 64, height: 64)), availableFilters: availableEffectors)
        effectSubMenuView.didSelectEffector = { effector in
            LCLoadingView.shared.show()
            DispatchQueue.global(qos: .utility).async {
                for editView in self.editableViews {
                    let output = effector.effector(image: editView.photoContentView.image)
                    DispatchQueue.main.sync {
                        editView.photoContentView.image = output
                    }
                }
                LCLoadingView.shared.hide()
            }
        }
        return effectSubMenuView
    }()
    
    public init(layoutType: MediaMontageType, images: [UIImage]) {
        self.layoutType = layoutType
        self.images = images
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemBackground
        
        initUI()
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
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
        
        let yPosition = kNavBarHeight + kTopToolBarHeight + kPadding
        let eHeight = mainToolbar.frame.origin.y - yPosition
        
        let editViewSize = CGSize(width: sWidth, height: eHeight)
        let slotSize = self.getSlotSize(editViewSize, layoutType: layoutType, ratioType: montageRatioType)
        
        var slotsWidth = slotSize.width
        var slotsHeight = slotSize.height
        
        if layoutType == .horizontalTwo || layoutType == .four {
            slotsWidth = slotsWidth * 2
        } else if layoutType == .horizontalThree || layoutType == .sixth {
            slotsWidth = slotsWidth * 3
        }
        
        if layoutType == .verticalTow || layoutType == .four || layoutType == .sixth {
            slotsHeight = slotsHeight * 2
        } else if layoutType == .verticalThree {
            slotsHeight = slotsHeight * 3
        }
    
        let eX: CGFloat = (sWidth - slotsWidth).half
        let eY: CGFloat = (eHeight - slotsHeight).half
        
        editview.frame = CGRect(x: kPadding + eX, y: yPosition + eY, width: slotsWidth, height: slotsHeight)
        self.view.addSubview(editview)
        
        var x: CGFloat = 0, y: CGFloat = 0
        
        for (index, image) in images.enumerated() {
            switch layoutType {
                case .verticalTow, .verticalThree:
                    y = slotSize.height * CGFloat(index)
                case .horizontalTwo, .horizontalThree:
                    x = slotSize.width * CGFloat(index)
                case .four:
                    x = slotSize.width * CGFloat(index % 2)
                    y = slotSize.height * CGFloat(Int(index / 2))
                case .sixth:
                    x = slotSize.width * CGFloat(index % 3)
                    y = slotSize.height * CGFloat(Int(index / 3))
                default:
                    print("default case")
            }
            
            let frame = CGRect(x: x, y: y, width: slotSize.width, height: slotSize.height)
            let editableView = LCEditableView(frame: frame, image: image)
            editview.addSubview(editableView)
            editableViews.append(editableView)
        }
    }
    
    // MARK: - Button Actions
    
    @objc func exportAction() {
//        syncImages()
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
//        syncImages()
        if index == 0 { // Correction filter
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
    
    func syncImages() {
        for editView in self.editableViews {
            editView.image = editView.scrollView.photoContentView.image
        }
    }
    
    // MARK: - Image Processing - Merge & Crop
    
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
            
            if fScale < frameScale {
                frameScale = fScale
            }
        }
        
        let newImage = mergeImages(images, frameScale)
        return newImage
        
    }
    
    /*
    func mergeImages(_ images: [UIImage], _ scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: editview.frame.size.width * scale, height: editview.frame.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        
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
    } */
    
    func mergeImages(_ images: [UIImage], _ scale: CGFloat) -> UIImage {
        var composite: CIImage?
        
        for (index, editView) in editableViews.enumerated() {
            let image = images[index]
            var ci = CIImage(image: image)!
            
            let zscale = editView.frame.size.width * scale / image.size.width
            ci = ci.transformed(by: CGAffineTransform(scaleX: zscale, y: zscale))
            ci = ci.transformed(by: CGAffineTransform(translationX: editView.frame.origin.x * scale, y: (editview.frame.size.height * scale - editView.frame.origin.y * scale)))

            if composite == nil {
                composite = ci
            } else {
                composite = ci.composited(over: composite!)
            }
            print("mergeIndex=\(index)")
        }
        
        let cgIntermediate = CIContext(options: nil).createCGImage(composite!, from: composite!.extent)
        let finalRenderedComposite = UIImage(cgImage: cgIntermediate!)
        print("New mergedImage's Size = \(finalRenderedComposite.size)")
        return finalRenderedComposite
    }
    
}
