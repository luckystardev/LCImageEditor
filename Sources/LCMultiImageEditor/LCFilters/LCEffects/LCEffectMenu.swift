//
//  LCEffectMenu.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/15/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

class LCEffectMenu: UIView {

   private let collectionView: UICollectionView
   private var availableEffectors: [LCEffectable]
   private var demoImages: [String:UIImage] = [:]
   private var selectedCellIndex: Int = 0
   private var isObservingCollectionView = true
   private var isFirst = true
   fileprivate let height_cell: CGFloat = 56
    
   public var didSelectEffector: (LCEffectable, _ value: CGFloat) -> Void = { _,_ in }
   
   private var colorSlider: ColorSlider?
   
   init() {
       let layout = UICollectionViewFlowLayout()
       layout.itemSize = CGSize(width: 52, height: height_cell)
       layout.minimumLineSpacing = 6
       layout.scrollDirection = .horizontal
       collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
       self.availableEffectors = kDefaultEffectors
       
       super.init(frame: .zero)
              
       self.addSubview(collectionView)
       collectionView.translatesAutoresizingMaskIntoConstraints = false
       collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
       collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
       collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
       collectionView.heightAnchor.constraint(equalToConstant: height_cell).isActive = true
       
       collectionView.register(LCEffectCell.classForCoder(), forCellWithReuseIdentifier: LCEffectCell.reussId)
       
       collectionView.backgroundColor = .clear
       collectionView.dataSource = self
       collectionView.delegate = self
       collectionView.showsHorizontalScrollIndicator = false
       collectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
       
       collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
       isObservingCollectionView = true
       
       self.backgroundColor = .clear
    
        colorSlider = ColorSlider(orientation: .horizontal, previewSide: .top)
        colorSlider?.delegate = self
        self.addSubview(colorSlider!)
    
        colorSlider?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorSlider!.leftAnchor.constraint(equalTo: leftAnchor, constant: kPadding.half),
            colorSlider!.rightAnchor.constraint(equalTo: rightAnchor, constant: -kPadding.half),
            colorSlider!.topAnchor.constraint(equalTo: topAnchor, constant: height_cell + 28),
            colorSlider!.heightAnchor.constraint(equalToConstant: 20),
        ])
    
        colorSlider?.isHidden = true
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

extension LCEffectMenu: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableEffectors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LCEffectCell.reussId, for: indexPath) as? LCEffectCell
            else { return UICollectionViewCell() }
        
        let effector = availableEffectors[indexPath.item]
        
        cell.imageView.image = effector.symbolImage()
        cell.name.text = effector.displayName()
        if indexPath.item == selectedCellIndex && !isFirst {
            cell.setSelected()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let effector = availableEffectors[indexPath.item]
        
        let prevSelectedCellIndex = selectedCellIndex
        
        selectedCellIndex = indexPath.item
        (collectionView.cellForItem(at: IndexPath(row: selectedCellIndex, section: 0)) as? LCEffectCell)?.setSelected()
        
        if !isFirst {
            collectionView.reloadItems(at: [IndexPath(row: prevSelectedCellIndex, section: 0)])
        }
        
        if indexPath.item == 0 {
            colorSlider?.isHidden = false
        } else {
            colorSlider?.isHidden = true
            didSelectEffector(effector, 0)
        }
        
        isFirst = false
    }
    
}

extension LCEffectMenu: ColorSliderDelegate {
    func colorPicked(_ value: CGFloat) {
        let effector = availableEffectors[0]
        didSelectEffector(effector, value)
    }
}
