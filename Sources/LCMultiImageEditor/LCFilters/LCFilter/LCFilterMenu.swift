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
    
    lazy var sliderView: LCSliderView = {
        var hSlider = LCSliderView.init(frame: CGRect.init(x: kPadding, y: 64, width: UIScreen.main.bounds.width - kPadding * 2, height: 56), tminValue: -100, tmaxValue: 100, tstep: 5, tNum: 5)
        hSlider.setDefaultValueAndAnimated(defaultValue: 0, animated: true)
        return hSlider
    }()
   
    init(appliedFilter: LCFilterable?) {
       
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 64)
        layout.minimumLineSpacing = 6
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
        collectionView.heightAnchor.constraint(equalToConstant: 64).isActive = true
    
        collectionView.register(LCFilterCell.classForCoder(), forCellWithReuseIdentifier: LCFilterCell.reussId)
       
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
       
        collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
        isObservingCollectionView = true
       
        self.backgroundColor = .clear
        collectionView.backgroundColor = .clear
    
        sliderView.delegate = self
        self.addSubview(sliderView)
        sliderView.isHidden = true
        
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.topAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        sliderView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        sliderView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sliderView.heightAnchor.constraint(equalToConstant: 56).isActive = true
   }
    
   public func resetFilterMenu() {
        for filter in availableFilters {
            filterValues[filter.filterName()] = 0.0
        }
        sliderView.setDefaultValueAndAnimated(defaultValue: 0, animated: true)
   }
    
   override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
       if let observedObject = object as? UICollectionView, observedObject == collectionView {
           collectionView.removeObserver(self, forKeyPath: "contentSize")
           isObservingCollectionView = false
           
           collectionView.scrollToItem(at: IndexPath(row: self.selectedCellIndex, section: 0), at: .centeredHorizontally, animated: false)
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
        return availableFilters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LCFilterCell.reussId, for: indexPath) as? LCFilterCell
            else { return UICollectionViewCell() }
        
        let filter = availableFilters[indexPath.item]
        
        
        if let value = filterValues[filter.filterName()] {
           selectedFilterValue = value
        } else {
            filterValues[filter.filterName()] = 0.0
        }
        
        cell.progressView.image = filter.symbolImage()
        cell.name.text = availableFilters[indexPath.item].filterName()
        if indexPath.item == selectedCellIndex && !isFirst {
            cell.setSelected()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = availableFilters[indexPath.item]
        
        let prevSelectedCellIndex = selectedCellIndex
        
        selectedCellIndex = indexPath.item
        (collectionView.cellForItem(at: IndexPath(row: selectedCellIndex, section: 0)) as? LCFilterCell)?.setSelected()
        
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
//            let minValue = filter.minimumValue()
//            sliderView.minValue = Float(minValue)
            
            let fValue = filterValues[filter.filterName()] ?? 0.0
            sliderView.setDefaultValueAndAnimated(defaultValue: Float(fValue), animated: false)
            sliderView.isHidden = false
//            sliderView.setDefaultValueAndAnimated(defaultValue: 0, animated: false)
            didSelectFilter(filter, 101)
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
        print("sliderValue=\(value)")
        if availbleChange {
            (collectionView.cellForItem(at: IndexPath(row: selectedCellIndex, section: 0)) as? LCFilterCell)?.updateProgress(value)
        }
    }
}
