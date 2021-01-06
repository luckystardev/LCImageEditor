//
//  LCMultiImageEditor+NSLayoutConstraints.swift
//  LCImageEditor
//
//  Created by LuckyClub on 1/6/21.
//  Copyright © 2021 LuckyClub. All rights reserved.
//

import UIKit

extension LCMultiImageEditor {
    
    func setupTopViewConstraints() {
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.topAnchor.constraint(equalTo: view.topAnchor, constant: kNavBarHeight).isActive = true
        topView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: kPadding).isActive = true
        topView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -kPadding).isActive = true
        topView.heightAnchor.constraint(equalToConstant: kTopToolBarHeight).isActive = true
    }
    
    func setupTitleLabelConstraints(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        label.widthAnchor.constraint(equalToConstant: 200).isActive = true
        label.heightAnchor.constraint(equalToConstant: kTopToolBarHeight).isActive = true
    }
    
    func setupCancelButtonConstraints(_ button: UIButton) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        button.leftAnchor.constraint(equalTo: topView.leftAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: kTopToolBarHeight).isActive = true
    }
    
    func setupResetButtonConstraints(_ button: UIButton) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.rightAnchor.constraint(equalTo: topView.rightAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 28).isActive = true
        button.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }
    
    func setupBottomViewConstraints() {
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -kBottomSafeAreaHeight).isActive = true
        bottomView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: kPadding).isActive = true
        bottomView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -kPadding).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: kBottomButtonHeight).isActive = true
        
        previewButton.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        previewButton.leftAnchor.constraint(equalTo: bottomView.leftAnchor).isActive = true
        previewButton.heightAnchor.constraint(equalToConstant: kBottomButtonHeight).isActive = true
        
        exportButton.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        exportButton.rightAnchor.constraint(equalTo: bottomView.rightAnchor).isActive = true
        exportButton.heightAnchor.constraint(equalToConstant: kBottomButtonHeight).isActive = true
        exportButton.leftAnchor.constraint(equalTo: previewButton.rightAnchor, constant: kPadding).isActive = true
        exportButton.widthAnchor.constraint(equalTo: previewButton.widthAnchor, multiplier: 1.0).isActive = true
    }
    
    func setupBottomToolbarConstraints() {
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomToolbar.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -kPadding).isActive = true
        bottomToolbar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: kPadding).isActive = true
        bottomToolbar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -kPadding).isActive = true
        bottomToolbar.heightAnchor.constraint(equalToConstant: kBottomToolBarHeight).isActive = true
    }
    
    func setupSegmentConstraints(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: bottomToolbar.centerXAnchor).isActive = true
        view.widthAnchor.constraint(equalToConstant: kBottomToolBarWidth).isActive = true
        view.centerYAnchor.constraint(equalTo: bottomToolbar.centerYAnchor).isActive = true
        view.heightAnchor.constraint(equalToConstant: kBottomToolBarHeight).isActive = true
    }
    
    func setupMainToolbarConstraints() {
        mainToolbar.translatesAutoresizingMaskIntoConstraints = false
        mainToolbar.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor, constant: -kPadding).isActive = true
        mainToolbar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: kPadding).isActive = true
        mainToolbar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -kPadding).isActive = true
        mainToolbar.heightAnchor.constraint(equalToConstant: kMainToolBarHeight).isActive = true
    }
    
    func setupFilterMenubarConstraints() {
        filterSubMenuView?.translatesAutoresizingMaskIntoConstraints = false
        filterSubMenuView?.topAnchor.constraint(equalTo: mainToolbar.topAnchor).isActive = true
        filterSubMenuView?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: kPadding).isActive = true
        filterSubMenuView?.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -kPadding).isActive = true
        filterSubMenuView?.heightAnchor.constraint(equalToConstant: kMainToolBarHeight).isActive = true
        
        effectSubMenuView?.translatesAutoresizingMaskIntoConstraints = false
        effectSubMenuView?.topAnchor.constraint(equalTo: mainToolbar.topAnchor).isActive = true
        effectSubMenuView?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: kPadding).isActive = true
        effectSubMenuView?.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -kPadding).isActive = true
        effectSubMenuView?.heightAnchor.constraint(equalToConstant: kMainToolBarHeight).isActive = true
    }
}
