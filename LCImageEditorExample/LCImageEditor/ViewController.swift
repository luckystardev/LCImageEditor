//
//  ViewController.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageview: UIImageView!
    var layoutType: MediaMontageType = .verticalThree
    var editType: EditType = .multiple
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageview.image = UIImage(named: "temp1")
        self.images = [UIImage(named: "img4")!, UIImage(named: "img3")!, UIImage(named: "img1")!] //
    }

    @IBAction func editorTypeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.editType = .multiple
        } else {
            self.editType = .single
        }
    }
        
    @IBAction func newButtonAction(_ sender: Any) {
        if editType == .multiple {
            chooseMultiLayoutType()
        } else {
            openPhotoLibrary()
        }
        
    }
    
    func chooseMultiLayoutType() {
        
        var alertStyle = UIAlertController.Style.actionSheet
        if (UIDevice.current.userInterfaceIdiom == .pad) {
          alertStyle = UIAlertController.Style.alert
        }
        
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: alertStyle)
        
        actionSheet.addAction(UIAlertAction(title: "verticalTow", style: .default) { (action) in
            self.layoutType = .verticalTow
            self.images = [UIImage(named: "IMG_2657")!, UIImage(named: "IMG_3792")!]
        })
        
        actionSheet.addAction(UIAlertAction(title: "horizontalTwo", style: .default) { (action) in
            self.layoutType = .horizontalTwo
            self.images = [UIImage(named: "IMG_2657")!, UIImage(named: "IMG_3802")!]
        })
        
        actionSheet.addAction(UIAlertAction(title: "verticalThree", style: .default) { (action) in
            self.layoutType = .verticalThree
            self.images = [UIImage(named: "IMG_2657")!, UIImage(named: "IMG_3792")!, UIImage(named: "IMG_3802")!]
        })
        
        actionSheet.addAction(UIAlertAction(title: "horizontalThree", style: .default) { (action) in
            self.layoutType = .horizontalThree
            self.images = [UIImage(named: "IMG_2657")!, UIImage(named: "IMG_3792")!, UIImage(named: "IMG_3802")!]
        })
        
        actionSheet.addAction(UIAlertAction(title: "four", style: .default) { (action) in
            self.layoutType = .four
            self.images = [UIImage(named: "IMG_2657")!, UIImage(named: "IMG_3792")!, UIImage(named: "IMG_3802")!, UIImage(named: "IMG_3412")!]
        })
        
        actionSheet.addAction(UIAlertAction(title: "sixth", style: .default) { (action) in
            self.layoutType = .sixth
            self.images = [UIImage(named: "IMG_2657")!, UIImage(named: "IMG_3792")!, UIImage(named: "IMG_3802")!, UIImage(named: "IMG_3412")!, UIImage(named: "IMG_3795")!, UIImage(named: "IMG_3799")!]
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        if editType == .multiple {
            print("Multiple edit mode")
            let vc = LCMultiImageEditor(layoutType: self.layoutType, images: self.images)
            vc.delegate = self
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        } else {
            print("Single edit mode")
            let vc = ImageEditorVC()
            vc.image = imageview.image
            vc.delegate = self
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @objc func openPhotoLibrary() {
        let pickerView = UIImagePickerController()
        pickerView.delegate = self
        pickerView.sourceType = .photoLibrary
        pickerView.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.present(pickerView, animated: true, completion: nil)
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            imageview.image = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: LCImageEditorDelegate {
    func lcImageEditor(_ controller: LCImageEditor, didFinishWithCroppedImage croppedImage: UIImage) {
        self.imageview?.image = croppedImage
        controller.dismiss(animated: true, completion: nil)
    }
    
    func lcImageEditorDidCancel(_ controller: LCImageEditor) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: MultiEditorDelegate {
    func multiEditor(_ controller: LCMultiImageEditor, didFinishWithCroppedImage exportedImage: UIImage) {
        self.imageview?.image = exportedImage
        controller.dismiss(animated: true, completion: nil)
    }
    
    func multiEditorDidCancel(_ controller: LCMultiImageEditor) {
        controller.dismiss(animated: true, completion: nil)
    }
}
