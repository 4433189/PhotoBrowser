//
//  MainViewController.swift
//  照片浏览器
//
//  Created by apple on 16/3/6.
//  Copyright © 2016年 xiaomage. All rights reserved.
//

import UIKit
import SDWebImage

class MainViewController: UICollectionViewController {
    // MARK:- 属性
    var shops : [Shop] = [Shop]()
    var pageIndex = 0
    private lazy var photoBrowserAnimator = PhotoBrowserAnimator()
    
    // MARK:- 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 加载数据
        loadData(pageIndex, offset: 0)
    }
}


// MARK:- 弹出照片浏览器
extension MainViewController {
    private func presentPhotoBrowser(indexPath : NSIndexPath) {
        // 1.创建图片浏览器
        let photoBrowserVc = PhotoBrowserController(shops: shops, currentIndexPath: indexPath)
        
        // 2.设置弹出样式为自定义
        photoBrowserVc.modalPresentationStyle = .Custom
        
        // 3.设置photoBrowserVc的转场代理
        photoBrowserVc.transitioningDelegate = photoBrowserAnimator
        
        // 4.设置photoBrowserAnimator的相关属性
        photoBrowserAnimator.setProperty(indexPath, presentedDelegate: self, dismissDelegate: photoBrowserVc)
        
        // 弹出图片浏览器
        presentViewController(photoBrowserVc, animated: true, completion: nil)
    }
}


// MARK:- 用于提供动画的内容
extension MainViewController : PhotoBrowserPresentedDelegate {
    func imageForPresent(indexPath: NSIndexPath) -> UIImageView {
        // 1.创建用于做动画的UIImageView
        let imageView = UIImageView()
        
        // 2.设置imageView属性
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        
        // 3.设置图片
        imageView.sd_setImageWithURL(shops[indexPath.item].picURL!, placeholderImage: UIImage(named: "empty_picture"))
        
        return imageView
    }
    
    func startRectForPresent(indexPath: NSIndexPath) -> CGRect {
        // 1.取出cell
        guard let cell = collectionView!.cellForItemAtIndexPath(indexPath) else {
            return CGRect(x: collectionView!.bounds.width * 0.5, y: UIScreen.mainScreen().bounds.height + 50, width: 0, height: 0)
        }
        
        // 2.计算转化为UIWindow上时的frame
        let startRect = collectionView!.convertRect(cell.frame, toCoordinateSpace: UIApplication.sharedApplication().keyWindow!)
        
        return startRect
    }
    
    func endRectForPresent(indexPath: NSIndexPath) -> CGRect {
        // 1.获取indexPath对应的URL
        let url = shops[indexPath.item].picURL!
        
        // 2.取出对应的image
         var image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(url.absoluteString)
        
        if image == nil {
            image = UIImage(named: "empty_picture")
        }
        
        // 3.根据image计算位置
        let screenW = UIScreen.mainScreen().bounds.width
        let screenH = UIScreen.mainScreen().bounds.height
        let imageH = screenW / image.size.width * image.size.height
        var y : CGFloat = 0
        if imageH < screenH {
            y = (screenH - imageH) * 0.5
        } else {
            y = 0
        }
        
        return CGRect(x: 0, y: y, width: screenW, height: imageH)
    }
}

// MARK:- collectionView的数据源和代理
extension MainViewController {
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shops.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // 1.创建cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("homeCellID", forIndexPath: indexPath) as! HomeViewCell
        
        // 2.给cell设置数据
        cell.shop = shops[indexPath.item]
        
        if indexPath.item == shops.count - 1 {
            pageIndex++
            loadData(pageIndex, offset: shops.count)
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        presentPhotoBrowser(indexPath)
    }
}


// MARK:- 请求网络数据
extension MainViewController {
    func loadData(page : Int, offset : Int) {
        NetworksTool.shareInstance.loadData(page, offset: offset) { (results, error) -> () in
            // 1.错误校验
            if error != nil {
                print(error)
                return
            }
            
            // 2.获取数据
            var tempShops = [Shop]()
            for shopDict in results! {
                tempShops.append(Shop(dict: shopDict))
            }
            
            self.shops += tempShops
            
            // 3.刷新表格
            self.collectionView?.reloadData()
        }
    }
}