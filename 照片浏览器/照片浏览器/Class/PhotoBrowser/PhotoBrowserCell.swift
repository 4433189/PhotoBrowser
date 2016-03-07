//
//  PhotoBrowserCell.swift
//  XMGWB
//
//  Created by apple on 16/3/3.
//  Copyright © 2016年 xiaomage. All rights reserved.
//

import UIKit
import SDWebImage

protocol PhotoBrowserCellDelegate : NSObjectProtocol {
    func photoBrowserCellImageClick()
}


class PhotoBrowserCell: UICollectionViewCell {
    // 代理属性
    var delegate : PhotoBrowserCellDelegate?
    
    // 属性
    var imageURL : NSURL? {
        didSet {
            // 1.错误校验
            guard let url = imageURL else {
                return
            }
            
            // 2.取出小图
            var smallImage = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(url.absoluteString)
            
            if smallImage == nil {
                smallImage = UIImage(named: "empty_picture")
            }
            
            // 3.计算imageView的位置和尺寸
            calculateImageFrame(smallImage)
            
            // 4.下载大图
            progressView.hidden = false
            imageView.sd_setImageWithURL(bigImageURL(url), placeholderImage: smallImage, options: [], progress: { (current, total) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.progressView.progress = CGFloat(current) / CGFloat(total)
                })
                
                }) { (image, _, _, _) -> Void in
                    
                    if image != nil {
                        self.calculateImageFrame(image)
                        self.imageView.image = image
                        self.progressView.hidden = true
                    }
            }
        }
    }
    
    /// 计算imageView的frame和显示位置
    private func calculateImageFrame(image : UIImage) {
        // 1.计算位置
        let imageWidth = UIScreen.mainScreen().bounds.width
        let imageHeight = image.size.height / image.size.width * imageWidth
        
        // 2.设置frame
        imageView.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        // 3.设置contentSize
        scrollView.contentSize = CGSize(width: imageWidth, height: imageHeight)
        
        // 4.判断是长图还是短图
        if imageHeight < UIScreen.mainScreen().bounds.height { // 短图
            // 设置偏移量
            let topInset = (UIScreen.mainScreen().bounds.height - imageHeight) * 0.5
            scrollView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        } else { // 长图
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    /// 获取大图的URL
    private func bigImageURL(smallURL : NSURL) -> NSURL {
        // 1.获取小图url的字符串
        let bigURLString = smallURL.absoluteString.stringByReplacingOccurrencesOfString("q", withString: "m")
        
        // 2.创建大图的URL
        return NSURL(string: bigURLString)!
    }
    
    // MARK:- 懒加载属性
    private lazy var progressView : ProgressView = ProgressView()
    lazy var imageView = UIImageView()
    lazy var scrollView = UIScrollView()
    
    // MARK:- 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension PhotoBrowserCell {
    private func setupUI() {
        // 1.添加子控件
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        contentView.addSubview(progressView)
        
        // 2.设置子控件的位置
        scrollView.frame = bounds
        scrollView.frame.size.width -= 20
        progressView.backgroundColor = UIColor.clearColor()
        progressView.hidden = true
        progressView.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
        progressView.center = CGPoint(x: contentView.bounds.width * 0.5 - 10, y: contentView.bounds.height * 0.5)
        
        // 4.设置scrollView的代理
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.7
        scrollView.maximumZoomScale = 1.5
        
        // 5.给imageView添加手势
        let tap = UITapGestureRecognizer(target: self, action: "closePhototBrowser")
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }
}

extension PhotoBrowserCell {
    @objc private func closePhototBrowser() {
        delegate?.photoBrowserCellImageClick()
    }
}

extension PhotoBrowserCell : UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // view : 被缩放的视图
    // scale : 当前缩放的比例
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        var topInset = (scrollView.bounds.height - view!.frame.size.height) * 0.5
        topInset = topInset < 0 ? 0 : topInset
        
        var leftInset = (scrollView.bounds.width - view!.frame.size.width) * 0.5
        leftInset = leftInset < 0 ? 0 : leftInset
        
        scrollView.contentInset = UIEdgeInsets(top: topInset, left: leftInset, bottom: 0, right: 0)
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        // 当缩小到一定比例,则自动退出控制器
        
    }
}
