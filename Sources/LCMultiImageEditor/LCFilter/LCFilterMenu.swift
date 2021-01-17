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
    private var demoImages: [String:UIImage] = [:]
    private var selectedCellIndex: Int = 0
    private var isObservingCollectionView = true
    private var isFirst = true
    
    public var didSelectFilter: (LCFilterable, _ value: Double) -> Void = { _,_  in }
    
    var availbleChange = false
    var selectedFilterValue: Double = 0
    var filterValues: [String:Double] = [:]
    
    var sliderView: LCSliderView = {
        var hSlider = LCSliderView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width - kPadding * 2, height: 56), tminValue: -100, tmaxValue: 100, tstep: 5, tNum: 5)
        hSlider.setDefaultValueAndAnimated(defaultValue: 0, animated: true)
        return hSlider
    }()
    
    public var image: UIImage {
        didSet {
            demoImages.removeAll()
            collectionView.reloadData()
        }
    }
   
    init(withImage image: UIImage, appliedFilter: LCFilterable?, availableFilters: [LCFilterable]) {
        self.image = image
       
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 64)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.availableFilters = availableFilters.count == 0 ? kDefaultAvailableFilters : availableFilters
       
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
        collectionView.contentInset = UIEdgeInsets(top: 0,left: 14,bottom: 0,right: 14)
       
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
        
        if let demo = demoImages[filter.filterName()] {
           cell.imageView.image = demo
        } else {
            let demo = filter.filter(image: image, value: selectedFilterValue)
            demoImages[filter.filterName()] = demo
            cell.imageView.image = demo
        }
        
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
            collectionView.reloadItems(at: [IndexPath(row: prevSelectedCellIndex, section: 0)])
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
            sliderView.setDefaultValueAndAnimated(defaultValue: 0, animated: false)
            sliderView.isHidden = false
        }
    }
}

extension LCFilterMenu: LCSliderDelegate {
    func LCSliderViewValueChange(sliderView: LCSliderView, value: Float) {
//        print("slider's value = \(value)")
        let filter = availableFilters[selectedCellIndex]
        if availbleChange {
            didSelectFilter(filter, Double(value))
        }
    }
}
