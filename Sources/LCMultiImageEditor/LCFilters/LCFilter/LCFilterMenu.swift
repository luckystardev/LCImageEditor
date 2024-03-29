//
//  LCFilterMenu.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/13/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

class LCFilterMenu: UIView {

    private let collectionView: UICollectionView
    private var availableFilters: [LCFilterable]
    private var selectedCellIndex: Int = 0
    private var isObservingCollectionView = true
    private var isFirst = true
    
    public var didSelectFilter: (LCFilterable, _ value: Double) -> Void = { _,_  in }
    
    var availbleChange = false
    var selectedFilterValue: Double = 0
    var filterValues: [String:Double] = [:]
    
    fileprivate let height_cell: CGFloat = 46
    fileprivate let width_cell: CGFloat  = 52
    
    lazy var sliderView: LCSliderView = {
        var hSlider = LCSliderView.init(frame: CGRect.init(x: kPadding, y: height_cell, width: UIScreen.main.bounds.width - kPadding * 2, height: 52), tminValue: -100, tmaxValue: 100, tstep: 5, tNum: 5)
        hSlider.setDefaultValueAndAnimated(defaultValue: 0, animated: true)
        return hSlider
    }()
   
    init(appliedFilter: LCFilterable?) {
       
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: width_cell, height: height_cell)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.availableFilters = kDefaultAvailableFilters
       
        super.init(frame: .zero)
       
        if let index = self.availableFilters.firstIndex(where: { return $0.filterName() == appliedFilter?.filterName() }) {
            self.selectedCellIndex = index
        }
       
        self.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: height_cell).isActive = true
    
        collectionView.register(LCFilterCell.classForCoder(), forCellWithReuseIdentifier: LCFilterCell.reussId)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "footerCell")
        
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
       
        collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
        isObservingCollectionView = true
       
        self.backgroundColor = .clear
    
        sliderView.delegate = self
        self.addSubview(sliderView)
        sliderView.isHidden = true
        
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.topAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        sliderView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        sliderView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sliderView.heightAnchor.constraint(equalToConstant: 52).isActive = true
   }
    
   public func resetFilterMenu() {
        for filter in availableFilters {
            filterValues[filter.filterName()] = 0.0
        }
        sliderView.setDefaultValueAndAnimated(defaultValue: 0, animated: true)
        collectionView.reloadData()
   }
    
   public override func layoutSubviews() {
       super.layoutSubviews()
       collectionView.collectionViewLayout.invalidateLayout()
   }
    
   override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
       if let observedObject = object as? UICollectionView, observedObject == collectionView {
           collectionView.removeObserver(self, forKeyPath: "contentSize")
           isObservingCollectionView = false
       }
   }
   
   required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
   
   deinit {
       if isObservingCollectionView {
           collectionView.removeObserver(self, forKeyPath: "contentSize")
       }
   }

}

extension LCFilterMenu: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableFilters.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 || indexPath.item == availableFilters.count + 1 {
            let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "footerCell", for: indexPath)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LCFilterCell.reussId, for: indexPath) as? LCFilterCell else { return UICollectionViewCell() }
                    
            let filter = availableFilters[indexPath.item - 1]
            
            if let value = filterValues[filter.filterName()] {
               selectedFilterValue = value
            } else {
                filterValues[filter.filterName()] = 0.0
            }
            
            cell.progressView.image = filter.symbolImage()
            if indexPath.item == selectedCellIndex && !isFirst {
                cell.setSelected()
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item > 0 || indexPath.item < availableFilters.count + 1 {
            let filter = availableFilters[indexPath.item - 1]
            let prevSelectedCellIndex = selectedCellIndex + 1
            
            selectedCellIndex = indexPath.item - 1
            (collectionView.cellForItem(at: IndexPath(row: selectedCellIndex, section: 0)) as? LCFilterCell)?.setSelected()
            
            collectionView.setContentOffset(CGPoint(x: CGFloat(selectedCellIndex * Int(width_cell + 10) - Int(width_cell / 3)), y: 0), animated: true)
            
            if !isFirst {
                (collectionView.cellForItem(at: IndexPath(row: prevSelectedCellIndex, section: 0)) as? LCFilterCell)?.setDeselected()
            }
            
            isFirst = false
            
            availbleChange = filter.valueChangeable()
            
            if !availbleChange {
                print("Not AvailableChange")
                sliderView.isHidden = true
                didSelectFilter(filter, 0)
            } else {
                
                let fValue = filterValues[filter.filterName()] ?? 0.0
                sliderView.setDefaultValueAndAnimated(defaultValue: Float(fValue), animated: false)
                sliderView.isHidden = false
                didSelectFilter(filter, 101)
            }
        }
    }
}

extension LCFilterMenu: LCSliderDelegate {
    func LCSliderViewValueDidChanged(sliderView: LCSliderView, value: Float) {
        let filter = availableFilters[selectedCellIndex]
        if availbleChange {
            filterValues[filter.filterName()] = Double(value)
            didSelectFilter(filter, Double(value))
        }
    }
    
    func LCSliderViewValueChange(sliderView: LCSliderView, value: Float) {
//        print("sliderValue = \(value)")
        if availbleChange {
            (collectionView.cellForItem(at: IndexPath(row: selectedCellIndex + 1, section: 0)) as? LCFilterCell)?.updateProgress(value)
        }
    }
}

extension LCFilterMenu: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 || indexPath.item == availableFilters.count + 1 {
            return CGSize(width: self.frame.size.width.half - width_cell, height: height_cell)
        }
        return CGSize(width: width_cell, height: height_cell)
    }
}
