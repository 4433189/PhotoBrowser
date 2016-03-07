//
//  HomeCollectionViewLayout.swift
//  照片浏览器
//
//  Created by apple on 16/3/6.
//  Copyright © 2016年 xiaomage. All rights reserved.
//

import UIKit

class HomeCollectionViewLayout: UICollectionViewFlowLayout {
    override func prepareLayout() {
        super.prepareLayout()
        
        // 1.定义间距和列数
        let margin : CGFloat = 10
        let col : CGFloat = 3
        
        // 2.计算item的宽度和高度
        let itemWH = (UIScreen.mainScreen().bounds.width - (col + 1) * margin) / 3
        
        // 3.设置布局
        itemSize = CGSize(width: itemWH, height: itemWH)
        minimumInteritemSpacing = margin
        minimumLineSpacing = margin
        
        // 4.设置内边距
        collectionView?.contentInset = UIEdgeInsets(top: 64 + margin, left: margin, bottom: 0, right: margin)
    }
}
