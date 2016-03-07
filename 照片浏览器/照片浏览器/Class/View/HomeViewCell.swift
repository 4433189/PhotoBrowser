//
//  HomeViewCell.swift
//  照片浏览器
//
//  Created by apple on 16/3/6.
//  Copyright © 2016年 xiaomage. All rights reserved.
//

import UIKit
import SDWebImage

class HomeViewCell: UICollectionViewCell {
    // 模型属性
    var shop : Shop? {
        didSet {
            imageView.sd_setImageWithURL(shop?.picURL, placeholderImage: UIImage(named: "empty_picture"), options: [.LowPriority, .RetryFailed])
        }
    }
    
    // 控件属性
    @IBOutlet weak var imageView: UIImageView!
}
