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
    var editMode: EditMode = .crop
    var montageRatioType: MontageRatioType = .custom
    
    var images: [UIImage]! = [UIImage]() //image collage
    
    public weak var delegate: MultiEditorDelegate?
    
    let topView = UIView()
    let editview = UIView()
    let bottomView = UIView()
    let bottomToolbar = UIView()
    let mainToolbar = UIView()
    let previewButton = CustomButton()
    let exportButton = CustomButton()
    let editBackgroundView = UIView()
    
    var editableViews = [LCEditableView]()
    var appliedFilter: LCFilterable!
    
    var previewImage: UIImage? = nil
    var selectedIndex: Int = 0
    
    var orientations = UIInterfaceOrientationMask.portrait
    
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        get {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return self.orientations
            };
            return .all
        }
        set { self.orientations = newValue }
    }
    lazy var croptoolbar: LCCropToolBar? = {
        let croptoolbar = LCCropToolBar.init(frame: CGRect(x: 0, y: (kMainToolBarHeight - kCropToolBarHeight).half, width: kCropToolBarWidth, height: kCropToolBarHeight))
        croptoolbar.config(selectedIndex: 0) { (index) in
            self.updateCropRatio(index)
        }
        return croptoolbar
    }()
    
    lazy var filterSubMenuView: LCFilterMenu? = {
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
                    let output = filter.filter(image: editView.ciImage!, value: value)
                    DispatchQueue.main.sync {
                        let context = CIContext(options: nil)
                        if let cgimg = context.createCGImage(output, from: output.extent) {
                                let uiimage =  UIImage(cgImage: cgimg)
                                editView.photoContentView.image = uiimage
                        }
                    }
                }
                LCLoadingView.shared.hide()
            }
        }
        return filterSubMenuView
    }()
    
    lazy var effectSubMenuView: LCEffectMenu? = {
        let availableEffectors = kDefaultEffectors
        let originImage = images.first
        let effectSubMenuView = LCEffectMenu(withImage: originImage!.resize(toSizeInPixel: CGSize(width: 64, height: 64)), availableFilters: availableEffectors)
        effectSubMenuView.didSelectEffector = { (effector, value) in
            LCLoadingView.shared.show()
            DispatchQueue.global(qos: .utility).async {
                for editView in self.editableViews {
                    let output = effector.effector(image: editView.photoContentView.image, value: value)
                    DispatchQueue.main.sync {
                        editView.photoContentView.image = output
                    }
                }
                LCLoadingView.shared.hide()
            }
        }
        return effectSubMenuView
    }()
    
    lazy private var previewView: ImageViewZoom? = {
        let imageView = ImageViewZoom(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        imageView.setup()
        imageView.imageContentMode = .aspectFit
        imageView.initialOffset = .center
        imageView.imageScrollViewDelegate = self
        return imageView
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
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initUI()
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            if UIDevice.current.orientation.isLandscape {
                print("Landscape")
            } else {
                print("Portrait")
            }
        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            self.setupEditableImageViews(.reset)
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // MARK: - Initialize UI
    
    func initUI() {
        setupTopView()
        setupBottomButtons()
        
        view.addSubview(previewView!)
        previewView?.isHidden = true
    }
    
    func setupTopView() {
        view.addSubview(topView)
        
        let titleLabel = UILabel()
        titleLabel.text = TITLE_COMPOSE
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        titleLabel.textAlignment = .center
        titleLabel.textColor = kTitleColor
        topView.addSubview(titleLabel)
        
        let cancelButton = UIButton()
        cancelButton.setTitle(TITLE_CANCEL, for: .normal)
        cancelButton.setTitleColor(kButtonTintColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        topView.addSubview(cancelButton)
        
        let resetButton = UIButton()
        resetButton.setBackgroundImage(UIImage(systemName: "arrow.2.circlepath"), for: .normal)
        resetButton.tintColor = kButtonTintColor
        resetButton.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        topView.addSubview(resetButton)
        
        self.setupTopViewConstraints()
        self.setupTitleLabelConstraints(titleLabel)
        self.setupCancelButtonConstraints(cancelButton)
        self.setupResetButtonConstraints(resetButton)
    }
    
    func setupBottomButtons() {
        view.addSubview(bottomView)
        
        previewButton.backgroundColor = .clear
        previewButton.setTitleColor(kButtonTintColor, for: .normal)
        previewButton.setTitle(TITLE_PREVIEW, for: .normal)
        previewButton.addTarget(self, action: #selector(previewAction), for: .touchUpInside)
        bottomView.addSubview(previewButton)
        
        exportButton.backgroundColor = kButtonTintColor
        exportButton.setTitle(TITLE_EXPORT, for: .normal)
        exportButton.addTarget(self, action: #selector(exportAction), for: .touchUpInside)
        bottomView.addSubview(exportButton)
        
        setupBottomViewConstraints()
        
        setupBottomToolbar()
    }
    
    func setupBottomToolbar() {
        view.addSubview(bottomToolbar)
        
        let segment = LCSegment.init(frame: CGRect.init(x: (self.view.frame.size.width - kBottomToolBarWidth).half, y: 0, width: kBottomToolBarWidth, height: kBottomToolBarHeight))
        
        let itemAttribute0 = LCSegmentItemAttribute.config(tintColor: UIColor.systemGray, imageName: "dial", selectedTintColor: UIColor.systemBlue)
        let itemAttribute1 = LCSegmentItemAttribute.config(tintColor: UIColor.systemGray, imageName: "wand.and.stars", selectedTintColor: UIColor.systemBlue)
        let itemAttribute2 = LCSegmentItemAttribute.config(tintColor: UIColor.systemGray, imageName: "crop", selectedTintColor: UIColor.systemBlue)
        segment.config(dataSource: [itemAttribute0, itemAttribute1, itemAttribute2],
                        selectedIndex: 2) { (index) in
            self.editControl(index)
        }
        
        bottomToolbar.addSubview(segment)
        
        setupBottomToolbarConstraints()
        setupSegmentConstraints(segment)
        
        setupMainToolBar()
    }
    
    func setupMainToolBar() {
        view.addSubview(mainToolbar)
        setupMainToolbarConstraints()
        
        setupFilterMenubar()
        
        view.addSubview(editBackgroundView)
        setupEditableImageViews(.new)
    }
    
    func setupFilterMenubar() {
        
        mainToolbar.addSubview(filterSubMenuView!)
        mainToolbar.addSubview(effectSubMenuView!)
        mainToolbar.addSubview(croptoolbar!)
        
        setupFilterMenubarConstraints()
        setupCropToolbarConstraints(croptoolbar!)
        
        filterSubMenuView?.isHidden = true
        effectSubMenuView?.isHidden = true
        croptoolbar?.isHidden = false
    }
    
    func setupEditableImageViews(_ type: setupImagesMode) {
        
        self.setupEditBgViewConstraints()
        self.editBackgroundView.layoutIfNeeded()
        
        let slotSize = self.getSlotSize(editBackgroundView.frame.size, layoutType: layoutType, ratioType: montageRatioType)
        
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
    
        let eX: CGFloat = (editBackgroundView.frame.size.width - slotsWidth).half
        let eY: CGFloat = (editBackgroundView.frame.size.height - slotsHeight).half
        
        editview.frame = CGRect(x: eX, y: eY, width: slotsWidth, height: slotsHeight)
        
        if type == .new {
            editBackgroundView.addSubview(editview)
            editableViews.removeAll()
        }
        
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
            
            if type == .new {
                let editableView = LCEditableView(frame: frame, image: image)
                editableView.delegate = self
                editview.addSubview(editableView)
                editableViews.append(editableView)
            } else if type == .reset {
                let view = editableViews[index]
                view.resetFrame(frame)
            } else if type == .edit && index == selectedIndex {
                let view = editableViews[index]
                view.removeFromSuperview()
                
                let editableView = LCEditableView(frame: frame, image: image)
                editableView.delegate = self
                editview.addSubview(editableView)
                editableViews[index] = editableView
            }
        }
    }
    
    // MARK: - Button Actions
    
    @objc func updateCropRatio(_ index: Int) {
        let ary: [MontageRatioType] = [.custom, .nineSixteenth, .threeFourth, .square, .fourThird, .sixteenNinth]
        if index < ary.count {
            self.montageRatioType = ary[index]
            self.setupEditableImageViews(.reset)
        }
    }
    
    @objc func exportAction() {
        cropImages(true)
    }
    
    @objc func backAction() {
        self.delegate?.multiEditorDidCancel(self)
    }

    @objc func previewAction() {
        cropImages(false)
        previewView!.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        previewView!.display(image: previewImage ?? UIImage())
        view.bringSubviewToFront(previewView!)
        previewView?.isHidden = false
    }
    
    @objc func resetAction() {
        syncImages()
        filterSubMenuView?.resetFilterMenu()
        for editView in self.editableViews {
            editView.ciImage = CIImage(image: editView.photoContentView.image)
        }
    }
    
    @objc func editControl(_ index: Int) {
        if index == 0 { // Correction filter
            self.editMode = .filter
            filterSubMenuView?.isHidden = false
            effectSubMenuView?.isHidden = true
            croptoolbar?.isHidden = true
            for editView in self.editableViews {
                editView.ciImage = CIImage(image: editView.photoContentView.image)
            }
            filterSubMenuView?.resetFilterMenu()
        } else if index == 1 { // Filter(effect)
            self.editMode = .effect
            filterSubMenuView?.isHidden = true
            effectSubMenuView?.isHidden = false
            croptoolbar?.isHidden = true
        } else { // crop
            self.editMode = .crop
            filterSubMenuView?.isHidden = true
            effectSubMenuView?.isHidden = true
            croptoolbar?.isHidden = false
        }
    }
    
    func syncImages() {
        for editView in self.editableViews {
            editView.photoContentView.image = editView.image
        }
    }
    
    // MARK: - Image Processing - Merge & Crop
    
     func cropImages(_ isExport: Bool) {
           
           //compose images
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
           
           //check export option - Full HD, 4K, Original
           checkExportOption(images, scale: frameScale, isExport: isExport)
       }
       
       private func checkExportOption(_ images: [UIImage], scale: CGFloat, isExport: Bool) {
           let scaleAry = getExpectScale(editview.frame.size, scale: scale)
           if scaleAry.count <= 1 {
               mergeImages(images, scale: scale, isExport: isExport)
           } else {
               if !isExport { //preview
                   mergeImages(images, scale: scaleAry.first!, isExport: isExport)
               } else { //export
                   var alertStyle = UIAlertController.Style.actionSheet
                   alertStyle = UIAlertController.Style.alert
                   
                   let actionSheet = UIAlertController(title: nil,
                                                       message: "Choose Export option",
                                                       preferredStyle: alertStyle)
                   
                   actionSheet.addAction(UIAlertAction(title: "Full HD", style: .default) { (action) in
                       self.mergeImages(images, scale: scaleAry.first!, isExport: isExport)
                   })
                   if scaleAry.count == 3 {
                       actionSheet.addAction(UIAlertAction(title: "4K", style: .default) { (action) in
                           self.mergeImages(images, scale: scaleAry[1], isExport: isExport)
                       })
                   }
                   actionSheet.addAction(UIAlertAction(title: "Original", style: .default) { (action) in
                       self.mergeImages(images, scale: scale, isExport: isExport)
                   })
                   present(actionSheet, animated: true, completion: nil)
               }
           }
       }
       
       private func mergeImages(_ images: [UIImage], scale: CGFloat, isExport: Bool) {
           var composite: CIImage?
           LCLoadingView.shared.show()
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
               print("mergeIndex = \(index)")
           }
           
           let cgIntermediate = CIContext(options: nil).createCGImage(composite!, from: composite!.extent)
           let finalRenderedComposite = UIImage(cgImage: cgIntermediate!)
           print("export Image's Size = \(finalRenderedComposite.size)")
           if !isExport { //preview
               self.previewImage = finalRenderedComposite
           } else { //export
               self.delegate?.multiEditor(self, didFinishWithCroppedImage: finalRenderedComposite)
           }
           DispatchQueue.global(qos: .utility).async {
               LCLoadingView.shared.hide()
           }
       }
    
}

extension LCMultiImageEditor: ImageViewZoomDelegate {
    public func closeAction(_ imageViewZoom: ImageViewZoom) {
        previewView?.isHidden = true
    }
}

extension LCMultiImageEditor: LCEditableViewDelegate {
    func tapAction(_ editableview: LCEditableView) {
        
        var alertStyle = UIAlertController.Style.actionSheet
        alertStyle = UIAlertController.Style.alert
        
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: alertStyle)
        /*
        actionSheet.addAction(UIAlertAction(title: "Edit", style: .default) { _ in
            //TODO: Edit single image
        }) */
        actionSheet.addAction(UIAlertAction(title: "Camera Roll", style: .default) { _ in
            self.setImageFromGallery(editableview)
        })
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func setImageFromGallery(_ editableview: LCEditableView) {
        PhotoRequestManager.requestPhotoLibrary(self){ result in
            switch result {
            case .success(let image):
                //TODO
                let index = self.editableViews.firstIndex(of: editableview)
                print(index as Any)
                if index! < self.images.count {
                    self.images[index!] = image
                    self.selectedIndex = index!
                    self.setupEditableImageViews(.edit)
                }
            case .faild:
                print("failed")
            case .cancel:
                break
            }
        }
    }
}
