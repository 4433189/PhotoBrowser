//
//  UIButton-Extension.swift
//  XMGWB
//
//  Created by apple on 16/2/25.
//  Copyright © 2016年 xiaomage. All rights reserved.
//

import UIKit

extension UIButton {
    convenience init(title : String, bgColor : UIColor, fontSize : CGFloat) {
        self.init()
        
        backgroundColor = bgColor
        setTitle(title, forState: .Normal)
        titleLabel?.font = UIFont.systemFontOfSize(fontSize)
    }
}
