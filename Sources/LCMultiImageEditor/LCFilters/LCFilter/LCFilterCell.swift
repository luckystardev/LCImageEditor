//
//  LCFilterCell.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/13/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

class LCFilterCell: UICollectionViewCell {
    static let reussId = String(describing: self)
    public var name: UILabel
    
    public var progressView: LCProgressView
    
    override init(frame: CGRect) {
        name = UILabel()
        progressView = LCProgressView()
        
        super.init(frame: frame)
        
        progressView.frame = CGRect(x: (frame.width - 42) / 2, y: 2, width: 42, height: 42)
        
        self.addSubview(progressView)
        self.addSubview(name)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        name.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        name.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        
        name.text = ""
        name.textColor = kDarkTextColor
        name.font = UIFont.systemFont(ofSize: 11)
    }
    
    override func prepareForReuse() {
        setDeselected()
    }
    
    public func setSelected() {
        name.textColor = kBlueColor
    }
    
    public func setDeselected() {
        name.textColor = kDarkTextColor
        progressView.updateStatus()
    }
    
    public func updateProgress(_ value: Float) {
        progressView.updateProgressCircle(value)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
