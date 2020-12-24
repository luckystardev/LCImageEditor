//
//  LCSegmentItem.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

public struct LCSegmentItemAttribute {
    
    var tintColor: UIColor
    var imageName: String
    var selectedTintColor: UIColor
    
    public static func config(tintColor: UIColor, imageName: String, selectedTintColor: UIColor) -> LCSegmentItemAttribute {
        return self.init(tintColor: tintColor, imageName: imageName, selectedTintColor: selectedTintColor)
    }
    
    public init(tintColor: UIColor, imageName: String, selectedTintColor: UIColor) {
        self.tintColor = tintColor
        self.imageName = imageName
        self.selectedTintColor = selectedTintColor
    }
}

class LCSegmentItem: UICollectionViewCell {
    
    fileprivate var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    func configSubviews() {
        self.contentView.backgroundColor = .systemBackground
        self.imageView = UIImageView.init(frame: CGRect(x: (self.bounds.width - kBottomToolBarHeight).half, y: (self.bounds.height - kBottomToolBarHeight).half, width: kBottomToolBarHeight, height: kBottomToolBarHeight))
        self.imageView?.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.imageView!)
    }

    public func update(with attribute:LCSegmentItemAttribute ,selected: Bool) {
        if selected {
            self.imageView?.image = UIImage(systemName: attribute.imageName)
            self.tintColor = UIColor.systemBlue
        } else {
            self.imageView?.image = UIImage(systemName: attribute.imageName)
            self.tintColor = UIColor.systemGray
        }
    }
}
