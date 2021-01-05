//
//  LCImageContentView.swift
//  LCImageEditor
//
//  Created by LuckyClub on 11/24/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

public class LCImageContentView: UIView {
    
    lazy fileprivate var imageView: UIImageView! = {
        let imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        return imageView
    }()
    
    public var image: UIImage! {
        didSet {
            self.imageView.frame = self.bounds
            self.imageView.image = self.image
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = self.bounds
    }
}
