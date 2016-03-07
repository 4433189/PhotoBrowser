//
//  Shop.swift
//  照片浏览器
//
//  Created by apple on 16/3/6.
//  Copyright © 2016年 xiaomage. All rights reserved.
//

import UIKit

class Shop: NSObject {
    var q_pic_url : String? {
        didSet {
            picURL = NSURL(string: q_pic_url ?? "")
        }
    }
    
    var picURL : NSURL?
    
    init(dict : [String : AnyObject]) {
        super.init()
        
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
}
