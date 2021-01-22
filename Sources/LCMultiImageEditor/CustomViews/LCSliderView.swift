//
//  LCSliderView.swift
//  LCImageEditorExample
//
//  Created by LuckyClub on 1/10/21.
//  Copyright © 2021 LuckyClub. All rights reserved.
//

import UIKit

fileprivate let markInterval = 12
fileprivate let yPosition: CGFloat = 8
fileprivate let sliderMaxY: CGFloat = 40
fileprivate let sliderHeight = 56

class LCRulerView: UIView {
    
    var minValue: Float = 0.0
    var maxValue: Float = 0.0
    var step: Float = 0.0
    var betweenNumber = 0
    
    override func draw(_ rect: CGRect) {
        
        let lineCenterX = CGFloat(markInterval)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineCap(CGLineCap.butt)
        context?.setStrokeColor(kBlackColor.cgColor)
        context?.setLineWidth(1)
        
        for i in 0...betweenNumber {
            context?.move(to: CGPoint.init(x: lineCenterX * CGFloat(i), y: 26))
            context!.addLine(to: CGPoint.init(x: lineCenterX * CGFloat(i), y: sliderMaxY))
            context!.strokePath()
            
            let num = Float(i) * step + minValue
            if num == 0 && (i == 0 || i == 5) {
                let rectangle = CGRect(x: (lineCenterX * CGFloat(i) - 4), y: yPosition + 2, width: 8, height: 8)
                context?.addEllipse(in: rectangle)
                context?.drawPath(using: .fill)
            }
        }
    }
}

protocol LCSliderDelegate: NSObjectProtocol {
    func LCSliderViewValueDidChanged(sliderView: LCSliderView, value: Float)
    func LCSliderViewValueChange(sliderView: LCSliderView, value: Float)
}

class LCSliderView: UIView {
    
    weak var delegate: LCSliderDelegate?
    
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
        
        self.backgroundColor = .systemBackground
        triangleview.frame = CGRect(x: (self.bounds.size.width - 1).half, y: yPosition, width: 2, height: sliderMaxY - yPosition)
        
        self.addSubview(self.lazyCollectionView)
        self.addSubview(self.triangleview)

        self.lazyCollectionView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: CGFloat(sliderHeight))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        triangleview.frame = CGRect(x: (self.bounds.size.width - 1).half, y: yPosition, width: 2, height: sliderMaxY - yPosition)
        self.lazyCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    lazy var lazyCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.estimatedItemSize = .zero
        
        let collectionView: UICollectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: CGFloat(sliderHeight)), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "footerCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "customeCell")

        return collectionView
    }()
    
    lazy var triangleview: UIView = {
        let triangleView = UIView()
        triangleView.backgroundColor = kBlackColor
        return triangleView
    }()
    
    @objc fileprivate func setRealValueAndAnimated(realValue: Float, animated: Bool) {
        fileRealValue = realValue
        lazyCollectionView.setContentOffset(CGPoint(x: CGFloat(realValue * Float(markInterval)), y: 0), animated: animated)
    }
    
    func setDefaultValueAndAnimated(defaultValue: Float, animated: Bool) {
        fileRealValue = defaultValue
        lazyCollectionView.setContentOffset(CGPoint.init(x: Int((defaultValue - minValue) / step) * markInterval, y: 0), animated: animated)
    }
}

extension LCSliderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stepCount + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 || indexPath.item == stepCount + 1 {
            let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "footerCell", for: indexPath)
            return cell
        } else {
            let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "customeCell", for: indexPath)
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
        var totalValue = value * step + minValue
        if scrollByHand {
            if totalValue >= maxValue {
                totalValue = maxValue
            } else if totalValue <= minValue {
                totalValue = minValue
            }
        }
        delegate?.LCSliderViewValueChange(sliderView: self, value: floor(totalValue))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        print("scrollViewDidEndDragging")
        if !decelerate {
            let realValue = Float(scrollView.contentOffset.x) / Float(markInterval)
            self.setRealValueAndAnimated(realValue: realValue, animated: true)
            delegate?.LCSliderViewValueDidChanged(sliderView: self, value: floor(realValue * step + minValue))
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
