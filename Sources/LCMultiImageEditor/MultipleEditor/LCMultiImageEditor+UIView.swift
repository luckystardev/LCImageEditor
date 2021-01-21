//
//  LCMultiImageEditor+UIView.swift
//  LCImageEditorExample
//
//  Created by LuckyClub on 1/21/21.
//  Copyright © 2021 LuckyClub. All rights reserved.
//

import UIKit

extension LCMultiImageEditor {
    
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
        
        let lockButton = UIButton()
        lockButton.setBackgroundImage(UIImage(systemName: "lock"), for: .normal)
        lockButton.tintColor = kButtonTintColor
        lockButton.addTarget(self, action: #selector(lockAction), for: .touchUpInside)
        topView.addSubview(lockButton)
        
        self.setupTopViewConstraints()
        self.setupTitleLabelConstraints(titleLabel)
        self.setupCancelButtonConstraints(cancelButton)
        self.setupResetButtonConstraints(resetButton)
        self.setupLockButtonConstraints(lockButton)
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
    
    private func setupBottomToolbar() {
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
    
    private func setupMainToolBar() {
        view.addSubview(mainToolbar)
        setupMainToolbarConstraints()
        
        setupFilterMenubar()
        
        view.addSubview(editBackgroundView)
        setupEditableImageViews(.new)
    }
    
    private func setupFilterMenubar() {
        
        mainToolbar.addSubview(filterSubMenuView!)
        mainToolbar.addSubview(effectSubMenuView!)
        mainToolbar.addSubview(croptoolbar!)
        
        setupFilterMenubarConstraints()
        setupCropToolbarConstraints(croptoolbar!)
        
        filterSubMenuView?.isHidden = true
        effectSubMenuView?.isHidden = true
        croptoolbar?.isHidden = false
    }
    
}
