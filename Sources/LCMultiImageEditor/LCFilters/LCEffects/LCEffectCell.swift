//
//  LCEffectCell.swift
//  LCImageEditorExample
//
//  Created by LuckyClub on 1/21/21.
//  Copyright © 2021 LuckyClub. All rights reserved.
//

import UIKit

class LCEffectCell: UICollectionViewCell {
    static let reussId = String(describing: self)
    public var imageView: UIImageView
    public var name: UILabel
    
    private var selectCircleView: UIView
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        name = UILabel()
        selectCircleView = UIView()
        
        super.init(frame: frame)
        
        selectCircleView.frame = CGRect(x: (frame.width - 42) / 2, y: 0, width: 42, height: 42)
        selectCircleView.layer.cornerRadius = selectCircleView.frame.width / 2
        selectCircleView.layer.borderWidth = 2
        selectCircleView.layer.borderColor = kGrayColor.cgColor
        
        imageView.frame = CGRect(x: 7, y: 7, width: 28, height: 28)
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tintColor = kBlackColor
        
        self.addSubview(selectCircleView)
        selectCircleView.addSubview(imageView)
        self.addSubview(name)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        name.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        name.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        
        name.text = ""
        name.textColor = kGrayColor
        name.font = UIFont.systemFont(ofSize: 12)
    }
    
    override func prepareForReuse() {
        setDeselected()
    }
    
    public func setSelected() {
        selectCircleView.layer.borderColor = kBlueColor.cgColor
        name.textColor = kBlueColor
    }
    
    public func setDeselected() {
        selectCircleView.layer.borderColor = kDarkTextColor.cgColor
        name.textColor = .darkText
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
