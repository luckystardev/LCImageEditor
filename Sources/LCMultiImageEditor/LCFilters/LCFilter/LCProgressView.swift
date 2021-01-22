//
//  LCProgressView.swift
//  LCImageEditorExample
//
//  Created by LuckyClub on 1/22/21.
//  Copyright © 2021 LuckyClub. All rights reserved.
//

import UIKit

class LCProgressView: UIView {

    private var bgCircle = CAShapeLayer()
    private var progressCircle = CAShapeLayer()
    
    private var circlePath = UIBezierPath()
    private var circlePathTnd = UIBezierPath()
    var statusProgress: Int = Int()
    
    private let π: CGFloat = CGFloat(Double.pi)
    private let circleColor: UIColor = .lightGray
    private let plusColor: UIColor = .orange
    private let minusColor: UIColor = .darkGray
    private let lineWidth: CGFloat = 2
    
    var valueProgress: CGFloat = 0
    var imageView: UIImageView = UIImageView()
    var image: UIImage?
    var titleLabel: UILabel = UILabel()
    
    private var centerPointArc: CGPoint = .zero
    private var radiusArc: CGFloat = 0
    
    // Method for calculate radian
    private func arc(arc: CGFloat) -> CGFloat {
        let results = ( π * arc ) / 180
        return results
    }
    
    override func draw(_ rect: CGRect) {

        // Create Path for ARC
        centerPointArc = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        radiusArc = self.frame.width / 2
        
        circlePath = UIBezierPath(arcCenter: centerPointArc, radius: radiusArc, startAngle: arc(arc: -90), endAngle: arc(arc: 270), clockwise: true)
        circlePathTnd = UIBezierPath(arcCenter: centerPointArc, radius: radiusArc, startAngle: arc(arc: -90), endAngle: arc(arc: -450), clockwise: false)
        
        // Define background circle progress
        bgCircle.path = circlePath.cgPath
        bgCircle.strokeColor = circleColor.cgColor
        bgCircle.fillColor = UIColor.clear.cgColor
        bgCircle.lineWidth = lineWidth
        bgCircle.strokeStart = 0
        bgCircle.strokeEnd = 100

        // Define real circle progress
        progressCircle.path = circlePath.cgPath
        progressCircle.strokeColor = plusColor.cgColor
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.lineWidth = lineWidth
        progressCircle.strokeStart = 0
        progressCircle.strokeEnd = valueProgress / 100
        
        // UIImageView
        imageView.frame = CGRect(x: bounds.minX + 7, y: bounds.minX + 7, width: circlePath.bounds.width - 14, height: circlePath.bounds.height - 14)
        imageView.image = image
//        imageView.layer.cornerRadius = imageView.frame.size.width / 2
//        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.black
        addSubview(imageView)
        
        // UILabel to display statusProgress
        titleLabel.frame = imageView.frame
        titleLabel.text = ""
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(titleLabel)
        titleLabel.isHidden = true
        
        // Set for sublayer circle progress
        layer.addSublayer(bgCircle)
        layer.addSublayer(progressCircle)
    }
    
    // Method for update status progress
    func updateProgressCircle(_ status: Float) {
        
        statusProgress = Int(status)
        
        titleLabel.isHidden = false
        imageView.isHidden = true
        
        if statusProgress >= 0 {
            progressCircle.path = circlePath.cgPath
            progressCircle.strokeColor = plusColor.cgColor
            titleLabel.textColor = plusColor
        } else {
            progressCircle.path = circlePathTnd.cgPath
            progressCircle.strokeColor = minusColor.cgColor
            titleLabel.textColor = minusColor
        }
        progressCircle.strokeEnd = abs(CGFloat(statusProgress)) / 100
        
        titleLabel.text = String(statusProgress)
    }
    
    func updateStatus() {
        titleLabel.isHidden = true
        imageView.isHidden = false
    }
    
    func resetProgressCircle() {
        progressCircle.strokeEnd = 0
    }

    private func changeBackgroundCircleProgressColor(_ stroke: UIColor, fill: UIColor) {
        bgCircle.strokeColor = stroke.cgColor
        bgCircle.fillColor = fill.cgColor
    }

    private func changeColorRealCircleProgress(_ stroke: UIColor, fill: UIColor) {
        progressCircle.strokeColor = stroke.cgColor
        progressCircle.fillColor = fill.cgColor
    }

}
