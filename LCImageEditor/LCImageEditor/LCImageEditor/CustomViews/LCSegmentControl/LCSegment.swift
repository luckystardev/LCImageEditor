//
//  LCSegmentedControl.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/12/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

public class LCSegment: UIView {
    
    public typealias LCSegmentSelectedBlock = (Int) -> Void

    fileprivate var collectionView: UICollectionView?
    
    fileprivate var dataSource: [LCSegmentItemAttribute]?
    
    fileprivate var selectedIndex: Int = 0
    
    fileprivate var selectedBlock: LCSegmentSelectedBlock?
    
    public func config(dataSource: [LCSegmentItemAttribute]?, selectedIndex: Int = 0, selectedBlock: @escaping LCSegmentSelectedBlock) {
        
        self.dataSource = dataSource
        
        self.selectedIndex = selectedIndex
        self.selectedBlock = selectedBlock
        
        let layout = LCSegmentFlowLayout()
        
        let collectionViewWidth = self.bounds.width
        let collectionViewHeight = self.bounds.height
        
        var itemWidth = collectionViewWidth
        if let dataSource = self.dataSource {
            if dataSource.count != 0 {
                itemWidth = itemWidth / CGFloat(dataSource.count)
            }
        }
        
        layout.config(itemSize: CGSize(width: itemWidth , height: collectionViewHeight))
        
        let collectionViewFrame = CGRect(x: 0, y: 0, width: collectionViewWidth, height: collectionViewHeight)
        self.collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self
        self.collectionView?.register(LCSegmentItem.self, forCellWithReuseIdentifier: "LCSegmentItem")
        self.collectionView?.isScrollEnabled = false
        self.addSubview(self.collectionView!)
        self.collectionView?.reloadData()
        
    }
    
}

extension LCSegment: UICollectionViewDelegate,UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dataSource = self.dataSource {
            return dataSource.count
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "LCSegmentItem", for: indexPath) as! LCSegmentItem
        item.update(with: self.dataSource![indexPath.item] ,selected: self.selectedIndex == indexPath.item)
        
        return item
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        if let block = self.selectedBlock {
            let selectedIndexPath = IndexPath.init(row: selectedIndex, section: 0)
            let selectedItem = collectionView.cellForItem(at: selectedIndexPath) as! LCSegmentItem
            selectedItem.update(with: self.dataSource![selectedIndexPath.item], selected: false)
            
            let currentSelectedItem = collectionView.cellForItem(at: indexPath) as! LCSegmentItem
            currentSelectedItem.update(with: self.dataSource![indexPath.item], selected: true)
            
            if self.selectedIndex != indexPath.item {
                block(indexPath.item)
                self.selectedIndex = indexPath.item
            }

        }
    }
}

public class LCSegmentFlowLayout: UICollectionViewFlowLayout {

    func config(itemSize: CGSize) {
        self.itemSize = itemSize
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 0.0
        self.minimumInteritemSpacing = 0.0
    }
}
