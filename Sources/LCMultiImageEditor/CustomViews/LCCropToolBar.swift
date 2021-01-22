//
//  LCCropToolBar.swift
//  LCImageEditorExample
//
//  Created by LuckyClub on 1/10/21.
//  Copyright © 2021 LuckyClub. All rights reserved.
//

import UIKit

public class LCCropToolBar: UIView {
    public typealias LCCropToolBarSelectedBlock = (Int) -> Void
    fileprivate var collectionView: UICollectionView?
    fileprivate let dataSource = ["Fit", "9:16", "3:4", "1:1", "4:3","16:9"]
    fileprivate var selectedIndex: Int = 0
    fileprivate var selectedBlock: LCCropToolBarSelectedBlock?
    
    public func config(selectedIndex: Int = 0, selectedBlock: @escaping LCCropToolBarSelectedBlock) {
        
        self.selectedIndex = selectedIndex
        self.selectedBlock = selectedBlock
        
        let layout = LCCropToolBarFlowLayout()
        
        let collectionViewWidth = self.bounds.width
        let collectionViewHeight = self.bounds.height
        
        let itemWidth = self.bounds.width / CGFloat(self.dataSource.count)
        
        layout.config(itemSize: CGSize(width: itemWidth , height: collectionViewHeight))
        
        let collectionViewFrame = CGRect(x: 0, y: 0, width: collectionViewWidth, height: collectionViewHeight)
        self.collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self
        self.collectionView?.register(LCCropToolBarItem.self, forCellWithReuseIdentifier: "LCCropToolBarItem")
        self.collectionView?.isScrollEnabled = false
        self.addSubview(self.collectionView!)
        self.collectionView?.reloadData()
        
    }
}

extension LCCropToolBar: UICollectionViewDelegate,UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "LCCropToolBarItem", for: indexPath) as! LCCropToolBarItem
        item.update(self.dataSource[indexPath.item] ,selected: self.selectedIndex == indexPath.item)
        
        return item
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        if let block = self.selectedBlock {
            let selectedIndexPath = IndexPath.init(row: selectedIndex, section: 0)
            let selectedItem = collectionView.cellForItem(at: selectedIndexPath) as! LCCropToolBarItem
            selectedItem.update(self.dataSource[selectedIndexPath.item], selected: false)
            
            let currentSelectedItem = collectionView.cellForItem(at: indexPath) as! LCCropToolBarItem
            currentSelectedItem.update(self.dataSource[indexPath.item], selected: true)
            
            if self.selectedIndex != indexPath.item {
                block(indexPath.item)
                self.selectedIndex = indexPath.item
            }
        }
    }
}

public class LCCropToolBarFlowLayout: UICollectionViewFlowLayout {

    func config(itemSize: CGSize) {
        self.itemSize = itemSize
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 0.0
        self.minimumInteritemSpacing = 0.0
    }
}

class LCCropToolBarItem: UICollectionViewCell {
    
    fileprivate var titleLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    func configSubviews() {
        self.contentView.backgroundColor = .systemBackground
        
        titleLabel = UILabel()
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        self.contentView.addSubview(titleLabel!)
        
        titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        titleLabel?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    public func update(_ title: String ,selected: Bool) {
        titleLabel?.text = title
        if selected {
            titleLabel?.textColor = kBlueColor
        } else {
            titleLabel?.textColor = kGrayColor
        }
    }
}
