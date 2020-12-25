//
//  ImageEditorVC.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

class ImageEditorVC: LCImageEditor {

    var horizontalDial: HorizontalDial? {
        didSet {
            self.horizontalDial?.migneticOption = .none
        }
    }
    
    // MARK: - initialize UI components
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addTopBar()
        addBootomMainToolBar()
        addHorizontalSliderBar()
    }
    
    func addTopBar() {
        let topbar = UIToolbar()
        topbar.frame = CGRect(x: 0, y: 44, width: self.view.frame.size.width, height: 50)
        var items = [UIBarButtonItem]()
        let backItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                       target: self,
                                       action: #selector(goBack))
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done,
                                          target: self,
                                          action: #selector(doneAction))
        
        items.append(backItem)
        items.append(space)
        items.append(doneItem)
        topbar.setItems(items, animated: true)
        topbar.tintColor = .white
        topbar.barTintColor = .clear
        view.addSubview(topbar)
    }
    
    func addBootomMainToolBar() {
        let topbar = UIToolbar()
        topbar.frame = CGRect(x: 0, y: self.view.frame.size.height - 80, width: self.view.frame.size.width, height: 50)
        var items = [UIBarButtonItem]()
        
        let cropItem = UIBarButtonItem(title: "Crop & Rotate", style: .done, target: self, action: #selector(cropRotateAction))
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let filterItem = UIBarButtonItem(title: "Filter", style: .done, target: self, action: #selector(filterAction))
        
        let space2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let textItem = UIBarButtonItem(title: "Text", style: .done, target: self, action: #selector(textAction))
        
        items.append(cropItem)
        items.append(space)
        items.append(filterItem)
        items.append(space2)
        items.append(textItem)
        
        topbar.setItems(items, animated: true)
        topbar.tintColor = .white
        topbar.barTintColor = .clear
        view.addSubview(topbar)
    }
    
    func addHorizontalSliderBar() {
        horizontalDial = HorizontalDial()
        horizontalDial?.frame = CGRect(x: 0, y: self.view.frame.size.height - 160, width: self.view.frame.size.width, height: 50)
        horizontalDial?.value = 0.0
        horizontalDial?.maximumValue = 80
        horizontalDial?.minimumValue = -80
        horizontalDial?.tick = 1
        horizontalDial?.centerMarkWidth = 3
        horizontalDial?.centerMarkRadius = 3
        horizontalDial?.markWidth = 1
        horizontalDial?.markCount = 30
        horizontalDial?.verticalAlign = "bottom"
        horizontalDial?.centerMarkHeightRatio = 0.8
        horizontalDial?.padding = 20
        horizontalDial?.enableRange = true
        horizontalDial?.markColor = .white
        horizontalDial?.centerMarkColor = .white
        horizontalDial?.delegate = self
        horizontalDial?.backgroundColor = .clear
        
        self.view.addSubview(horizontalDial!)
    }
    
    // MARK: - ButtonItem Actions
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneAction() {
        cropAction()
    }
    
    @objc func cropRotateAction() {
        print("cropRotateAction")
    }
    
    @objc func filterAction() {
        print("filterAction")
    }
    
    @objc func textAction() {
        print("textAction")
    }
    
    // MARK: - Rotation
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.view.layoutIfNeeded()
        }) { (context) in
            //
        }
    }
    
    override open func customCanvasInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: UIDevice.current.orientation.isLandscape ? 40.0 : 100.0,
                            left: 0,
                            bottom: 0,
                            right: 0)
    }
    
}

extension ImageEditorVC: HorizontalDialDelegate {
    func horizontalDialDidValueChanged(_ horizontalDial: HorizontalDial) {
        let degrees = horizontalDial.value
        print("value = \(degrees)")
        let radians = LCRadian.toRadians(CGFloat(degrees))
        
        self.changeAngle(radians: radians)
    }
    
    func horizontalDialDidEndScroll(_ horizontalDial: HorizontalDial) {
        print("stopChangeAngle")
        self.stopChangeAngle()
    }
}
