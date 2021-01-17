//
//  LCSliderView.swift
//  LCImageEditorExample
//
//  Created by LuckyClub on 1/10/21.
//  Copyright © 2021 LuckyClub. All rights reserved.
//

import UIKit

fileprivate let markInterval     = 12
fileprivate let longLineHeight   = 40
fileprivate let shortLineHeight  = 35
fileprivate let triangleWidth    = 12
fileprivate let sliderHeight     = 56
fileprivate let triangleColor    = UIColor.blue

class LCTriangleView: UIView {
    
    override func draw(_ rect: CGRect) {
        UIColor.clear.set()
        UIRectFill(self.bounds)
        
        let context = UIGraphicsGetCurrentContext()
        context!.beginPath()
        context!.move(to: CGPoint.init(x: 0, y: 0))
        context!.addLine(to: CGPoint.init(x: triangleWidth, y: 0))
        context!.addLine(to: CGPoint.init(x: triangleWidth/2, y: triangleWidth/2))
        context!.setLineCap(CGLineCap.butt)
        context!.setLineJoin(CGLineJoin.bevel)
        context!.closePath()
        
        triangleColor.setFill()
        triangleColor.setStroke()
        context!.drawPath(using: CGPathDrawingMode.fillStroke)
    }
}

class LCRulerView: UIView {
    
    var minValue: Float = 0.0
    var maxValue: Float = 0.0
    var step: Float = 0.0
    var betweenNumber = 0
    
    override func draw(_ rect: CGRect) {
        let lineCenterX = CGFloat(markInterval)
        let shortLineY = rect.size.height - CGFloat(longLineHeight)
        let longLineY = rect.size.height - CGFloat(shortLineHeight)
        let topY:CGFloat = 0
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineCap(CGLineCap.butt)
        
        for i in 0...betweenNumber {
            context?.setLineWidth(1)
            context?.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            context?.move(to: CGPoint.init(x: lineCenterX * CGFloat(i), y: topY))
            if i % betweenNumber == 0 {
                let num = Float(i)*step+minValue
                if num == 0 && i == 0 {
                    context?.setLineWidth(3)
                    context?.setStrokeColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
                }
                context!.addLine(to: CGPoint.init(x: lineCenterX * CGFloat(i), y: longLineY))
            } else {
                context!.addLine(to: CGPoint.init(x: lineCenterX * CGFloat(i), y: shortLineY))
            }
            context!.strokePath()
        }
    }
}

protocol LCSliderDelegate: NSObjectProtocol {
    func LCSliderViewValueChange(sliderView: LCSliderView, value: Float)
}

class LCSliderView: UIView {
    
    weak var delegate:LCSliderDelegate?
    
    var scrollByHand = true
    var stepCount = 0
    private var redLine: UIImageView?
    private var fileRealValue: Float = 0.0
    public var minValue: Float = 0.0
    var maxValue: Float = 0.0
    var step: Float = 0.0
    var betweenNum: Int = 0
    
    init(frame: CGRect, tminValue: Float, tmaxValue: Float, tstep: Float, tNum: Int) {
        
        super.init(frame: frame)
        
        minValue    = tminValue
        maxValue    = tmaxValue
        betweenNum  = tNum
        step        = tstep
        stepCount   = Int((tmaxValue - tminValue) / step) / betweenNum
        
        self.backgroundColor = UIColor.white
        valueLbl.frame = CGRect(x: (self.bounds.size.width - 60).half, y: 0, width: 60, height: 20)
        triangleview.frame = CGRect(x: (self.bounds.size.width - CGFloat(triangleWidth) - 1).half, y: valueLbl.frame.maxY, width: CGFloat(triangleWidth), height: CGFloat(triangleWidth))
        
        self.addSubview(self.valueLbl)
        self.addSubview(self.lazyCollectionView)
        self.addSubview(self.triangleview)

        self.lazyCollectionView.frame = CGRect.init(x: 0, y: 20, width: self.bounds.size.width, height: CGFloat(sliderHeight - 20))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        valueLbl.frame = CGRect(x: (self.bounds.size.width - 60).half, y: 0, width: 60, height: 20)
        triangleview.frame = CGRect(x: (self.bounds.size.width - CGFloat(triangleWidth) - 1).half, y: valueLbl.frame.maxY, width: CGFloat(triangleWidth), height: CGFloat(triangleWidth))
        self.lazyCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    var valueLbl: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    lazy var lazyCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        let collectionView:UICollectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: CGFloat(sliderHeight)), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.systemBackground
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "footerCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "customeCell")

        return collectionView
    }()
    
    lazy var triangleview: LCTriangleView = {
        let triangleView = LCTriangleView()
        triangleView.backgroundColor = UIColor.clear
        return triangleView
    }()
    
    @objc fileprivate func didChangeCollectionValue() {
        let textFieldValue = Float(valueLbl.text!)
        if (textFieldValue! - minValue) >= 0 {
            self.setRealValueAndAnimated(realValue: (textFieldValue! - minValue) / step, animated: true)
        }
    }
    
    @objc fileprivate func setRealValueAndAnimated(realValue: Float, animated: Bool){
        fileRealValue = realValue
        valueLbl.text = String.init(format: "%.0f", floor(fileRealValue * step + minValue))
        lazyCollectionView.setContentOffset(CGPoint(x: CGFloat(realValue * Float(markInterval)), y: 0), animated: animated)
    }
    
    func setDefaultValueAndAnimated(defaultValue: Float, animated: Bool) {
        fileRealValue = defaultValue
        valueLbl.text = String.init(format: "%.0f", defaultValue)
        lazyCollectionView.setContentOffset(CGPoint.init(x: Int((defaultValue - minValue) / step) * markInterval, y: 0), animated: animated)
    }
}

extension LCSliderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stepCount + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 || indexPath.item == stepCount + 1 {
            let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "footerCell", for: indexPath)
            return cell
        } else {
            let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "customeCell", for: indexPath)
            var rulerView: LCRulerView? = cell.contentView.viewWithTag(1002) as? LCRulerView
            if rulerView == nil {
                rulerView = LCRulerView.init(frame: CGRect.init(x: 0, y: 0, width: markInterval * betweenNum, height: sliderHeight))
                rulerView!.backgroundColor = UIColor.clear
                rulerView!.step = step
                rulerView!.tag = 1002
                rulerView!.betweenNumber = betweenNum;
                cell.contentView.addSubview(rulerView!)
            }
            
            rulerView!.minValue = step * Float((indexPath.item - 1)) * Float(betweenNum) + minValue
            rulerView!.maxValue = step * Float(indexPath.item) * Float(betweenNum)
            rulerView!.setNeedsDisplay()
 
            return cell
        }
    }
}

extension LCSliderView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = Float(scrollView.contentOffset.x) / Float(markInterval)
        let totalValue = value * step + minValue
        if scrollByHand {
            if totalValue >= maxValue {
                valueLbl.text = String.init(format: "%.0f", maxValue)
            } else if totalValue <= minValue {
                valueLbl.text = String.init(format: "%.0f", minValue)
            } else{
                valueLbl.text = String.init(format: "%.0f", floor(Float(value) * step + minValue))
            }
        }
//            delegate?.LCSliderViewValueChange(sliderView: self, value: totalValue)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        print("scrollViewDidEndDragging")
        if !decelerate {
            let realValue = Float(scrollView.contentOffset.x) / Float(markInterval)
            self.setRealValueAndAnimated(realValue: realValue, animated: true)
            delegate?.LCSliderViewValueChange(sliderView: self, value: floor(realValue * step + minValue))
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let realValue = Float(scrollView.contentOffset.x) / Float(markInterval)
        self.setRealValueAndAnimated(realValue: realValue, animated: true)
        delegate?.LCSliderViewValueChange(sliderView: self, value: floor(realValue * step + minValue))
    }
}

extension LCSliderView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 || indexPath.item == stepCount + 1 {
            return CGSize(width: Int(self.frame.size.width.half), height: sliderHeight)
        }
        return CGSize(width: markInterval * betweenNum, height: sliderHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
