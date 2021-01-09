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
   
    var horizontalDial: HorizontalDial?
    var percentLabel = UILabel()
    
    var availbleChange = false
    var selectedFilterValue: Double = 0
    var filterValues: [String:Double] = [:]
    
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
    
        // add percent label
        percentLabel.frame = .zero
        self.updatePercentLabel(selectedFilterValue)
        self.addSubview(percentLabel)
    
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        percentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 66).isActive = true
        percentLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        // add horizontalDial
        horizontalDial = HorizontalDial()
        horizontalDial?.frame = .zero
        horizontalDial?.delegate = self
        self.addSubview(horizontalDial!)
    
        horizontalDial!.translatesAutoresizingMaskIntoConstraints = false
        horizontalDial!.topAnchor.constraint(equalTo: percentLabel.bottomAnchor).isActive = true
        horizontalDial!.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        horizontalDial!.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        horizontalDial!.heightAnchor.constraint(equalToConstant: 36).isActive = true
    
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
        updateHorizontalDial(filter)
        if !availbleChange {
            print("Not AvailableChange")
            horizontalDial?.isHidden = true
            didSelectFilter(filter, 0)
        } else {
            print("AvailableChange")
            horizontalDial?.isHidden = false
        }
        
    }
    
    func updateHorizontalDial(_ filter: LCFilterable) {
        selectedFilterValue = filterValues[filter.filterName()] ?? 0.0
        
        updatePercentLabel(selectedFilterValue)
        
        let minValue = filter.minimumValue()
        horizontalDial?.animateWithValueUpdate(selectedFilterValue)
        horizontalDial?.minimumValue = minValue
    }
    
}

extension LCFilterMenu: HorizontalDialDelegate {
    public func horizontalDialDidValueChanged(_ horizontalDial: HorizontalDial) {
        var value = floor(horizontalDial.value)
        
        if value > horizontalDial.maximumValue {
            value = horizontalDial.maximumValue
        } else if value < horizontalDial.minimumValue {
            value = horizontalDial.minimumValue
        }
        self.updatePercentLabel(value)
    }
    
    public func horizontalDialDidEndScroll(_ horizontalDial: HorizontalDial) {
        var value = floor(horizontalDial.value)
        
        if value > horizontalDial.maximumValue {
            value = horizontalDial.maximumValue
        } else if value < horizontalDial.minimumValue {
            value = horizontalDial.minimumValue
        }
        
        let filter = availableFilters[selectedCellIndex]
        if availbleChange {
            selectedFilterValue = value
            filterValues[filter.filterName()] = value
            didSelectFilter(filter, value)
        }
    }
    
    func updatePercentLabel(_ value: Double) {
        self.percentLabel.text = String(Int(value)) + "%"
    }
}
