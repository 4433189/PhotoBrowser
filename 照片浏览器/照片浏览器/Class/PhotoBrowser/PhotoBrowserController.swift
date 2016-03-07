//
//  PhotoBrowserController.swift
//  XMGWB
//
//  Created by apple on 16/3/3.
//  Copyright © 2016年 xiaomage. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage

private let PhotoCellID = "PhotoCellID"

// 图片间距
private let PicMargin : CGFloat = 20

class PhotoBrowserController: UIViewController {
    
    // MARK:- 属性
    private var shops : [Shop]
    private var currentIndexPath : NSIndexPath
    
    // MARK:- 懒加载子控件
    private lazy var collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: PhotoCollectionViewLayout())
    private lazy var closeBtn : UIButton = UIButton(title: "关闭", bgColor: UIColor.darkGrayColor(), fontSize: 14)
    private lazy var saveBtn : UIButton = UIButton(title: "保存", bgColor: UIColor.darkGrayColor(), fontSize: 14)
    
    
    // MARK:- 构造函数
    init(shops : [Shop], currentIndexPath : NSIndexPath) {
        self.shops = shops
        self.currentIndexPath = currentIndexPath
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.frame.size.width += PicMargin
    }
    
    // MARK:- 系统的回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.设置子控件
        setupUI()
        
        // 2.滚到指定位置
        collectionView.scrollToItemAtIndexPath(currentIndexPath, atScrollPosition: .CenteredHorizontally, animated: false)
    }
}

// 设置子控件
extension PhotoBrowserController {
    /// 设置子控件
    private func setupUI() {
        // 1.添加子控件
        view.addSubview(collectionView)
        view.addSubview(closeBtn)
        view.addSubview(saveBtn)
        
        // 2.布局子控件
        let btnHMargin : CGFloat = 20
        let btnVMargin : CGFloat = 10
        let btnW : CGFloat = 100
        let btnH : CGFloat = 32
        closeBtn.frame = CGRect(x: btnHMargin, y: view.bounds.height - btnH - btnVMargin, width: btnW, height: btnH)
        saveBtn.frame = CGRect(x: view.bounds.width - PicMargin - btnW - btnHMargin, y: view.bounds.height - btnVMargin - btnH, width: btnW, height: btnH)
        collectionView.frame = view.bounds
        
        
        // 3.监听按钮的点击
        closeBtn.addTarget(self, action: "closeBtnClick", forControlEvents: .TouchUpInside)
        saveBtn.addTarget(self, action: "saveBtnClick", forControlEvents: .TouchUpInside)
        
        // 4.准备collectionView的属性
        collectionView.dataSource = self
        collectionView.registerClass(PhotoBrowserCell.self, forCellWithReuseIdentifier: PhotoCellID)
    }
    
    @objc private func closeBtnClick() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func saveBtnClick() {
        // 1.获取cell
        guard let cell = collectionView.visibleCells()[0] as? PhotoBrowserCell else {
            return
        }
        
        // 2.取出cell中的图片进行保存
        guard let image = cell.imageView.image else {
            return
        }
        
        // 3.将图片写入相册
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    // - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
    @objc private func image(image : UIImage, didFinishSavingWithError error : NSError?, contextInfo context : AnyObject) {
        // 1.判断是否有错误
        let message = error == nil ? "保存成功" : "保存失败"
        
        // 2.显示保存结果
        SVProgressHUD.showInfoWithStatus(message, maskType: .None)
    }
}

// MARK:- UICollectionViewDataSource
extension PhotoBrowserController : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shops.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // 1.创建cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCellID, forIndexPath: indexPath) as! PhotoBrowserCell
        
        // 2.给cell设置数据
        let imageURL = shops[indexPath.item].picURL
        cell.imageURL = imageURL
        cell.delegate = self
        
        // 3.自动下载下一张图片
        downloadNextImage(indexPath.item + 1)
        
        // 4.返回cell
        return cell
    }
    
    private func downloadNextImage(index : Int) {
        // 1.判断是否有下一张图片
        if index > shops.count - 1 {
            return
        }
        
        // 2.下载图片
        let url = shops[index].picURL!
        SDWebImageManager.sharedManager().downloadImageWithURL(url, options: .RetryFailed, progress: nil) { (_, _, _, _, _) -> Void in
            
        }
    }
}


// MARK:- 内部点击
extension PhotoBrowserController : PhotoBrowserCellDelegate {
    func photoBrowserCellImageClick() {
        closeBtnClick()
    }
}


extension PhotoBrowserController : PhotoBrowserDismissDelegate {
    func imageViewForDismiss() -> UIImageView {
        // 1.创建UIImageView对象
        let tempImageView = UIImageView()
        
        // 2.设置属性
        tempImageView.contentMode = .ScaleAspectFill
        tempImageView.clipsToBounds = true
        
        // 3.设置图片
        let cell = collectionView.visibleCells()[0] as! PhotoBrowserCell
        tempImageView.image = cell.imageView.image
        tempImageView.frame = cell.scrollView.convertRect(cell.imageView.frame, toCoordinateSpace: UIApplication.sharedApplication().keyWindow!)
        
        return tempImageView
    }
    
    func indexPathForDismiss() -> NSIndexPath {
        return collectionView.indexPathsForVisibleItems()[0]
    }
}


class PhotoCollectionViewLayout : UICollectionViewFlowLayout {
    override func prepareLayout() {
        super.prepareLayout()
        
        // 1.布局属性设置
        itemSize = collectionView!.bounds.size
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = .Horizontal
        
        // 2.设置collectionView的属性
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.pagingEnabled = true
    }
}
