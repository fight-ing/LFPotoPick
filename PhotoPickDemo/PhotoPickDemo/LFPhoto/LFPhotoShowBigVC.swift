//
//  LFPhotoShowBigVC.swift
//  PhotoPickDemo
//
//  Created by fei on 2017/8/29.
//  Copyright © 2017年 self. All rights reserved.
//

import UIKit
import Photos

/**
 *  大图展示
 */

class LFPhotoShowBigVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    //顶部view
    @IBOutlet var topView: UIView!
    //底部view
    @IBOutlet var bottomView: UIView!
    //选择
    @IBOutlet var checkButton: UIButton!
    var completeButton: LFCompleteButton!
    
    @IBOutlet var collectionView: UICollectionView!
    //最多可选照片数
    var maxSelected:Int = Int.max
    
    //照片选择完成之后回调
    var completeHandle:((_ assets:[PHAsset]) -> ())?
    
    //对应相册数据
    var assetsFetchResults:PHFetchResult<PHAsset>?
    
    var selectedDataArray:[NSIndexPath] = []
    
    //带缓存的图片管理对象
    var imageManager:PHCachingImageManager!
    
    //缩略图大小
    var assetGridThumbnailSize:CGSize!
    
    var currentIndex:NSIndexPath!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        let scale = UIScreen.main.scale
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        assetGridThumbnailSize = CGSize(width: cellSize.width*scale, height: cellSize.height*scale)
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.isHidden = false;
        collectionView.setContentOffset(CGPoint.init(x: (CGFloat(currentIndex.row) * collectionView.frame.size.width), y: 0), animated: false);
        scrollViewDidEndDecelerating(collectionView)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化和重置缓存
        self.imageManager = PHCachingImageManager()
        self.resetCachedAssets()
        
        //设置单元格尺寸
        let layout = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        
        
        completeButton = LFCompleteButton()
        completeButton.addTarget(target: self, action: #selector(completeButtonClicked))
        completeButton.center = CGPoint(x: UIScreen.main.bounds.size.width - 35, y: bottomView.frame.size.height/2)
        completeButton.num = self.selectedDataArray.count
        completeButton.isEnabled = self.selectedDataArray.count != 0
        bottomView.addSubview(completeButton)
        
        collectionView.isHidden = true;
        
    }
    
    //点击完成
    func completeButtonClicked()  {
        //取出已选择的图片资源
        var assets:[PHAsset] = []
        if let indexPaths = self.collectionView.indexPathsForSelectedItems{
            for indexPath in indexPaths{
                assets.append(assetsFetchResults![indexPath.row] )
            }
        }
        //调用回调函数
        self.navigationController?.dismiss(animated: true, completion: {
            self.completeHandle?(assets)
        })
    }
    
    //选择/取消
    @IBAction func checkButtonClicked(_ sender: UIButton) {
        let point = collectionView.contentOffset;
        let indexPath = collectionView.indexPathForItem(at: point)
        if selectedDataArray.count < maxSelected {
            if let i = selectedDataArray.index(of: indexPath! as NSIndexPath) {
                selectedDataArray.remove(at: i)
            } else {
                selectedDataArray.append(indexPath! as NSIndexPath)
            }
            completeButton.num = selectedDataArray.count;
            if selectedDataArray.count == 0 {
                completeButton.isEnabled = false;
            } else {
                completeButton.isEnabled = true;
            }
        } else if selectedDataArray.count == maxSelected {
            if let i = selectedDataArray.index(of: indexPath! as NSIndexPath) {
                selectedDataArray.remove(at: i)
                completeButton.num = selectedDataArray.count;
                if selectedDataArray.count > 0 && !self.completeButton.isEnabled {
                    completeButton.isEnabled = true;
                }
            } else {
                showAlertOfMaxnumber()
            }
        } else {
            showAlertOfMaxnumber()
        }
        self.refreshSeletedStatus(indexPath: indexPath! as NSIndexPath);
    }
    
    func refreshSeletedStatus(indexPath:NSIndexPath)  {
        if selectedDataArray.index(of: indexPath as NSIndexPath) != nil {
            checkButton.isSelected = true;
        } else {
            checkButton.isSelected = false;
        }
    }
    
    //重置缓存
    func resetCachedAssets(){
        self.imageManager.stopCachingImagesForAllAssets()
    }

    
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        let collectionVC:LFPhotoCollectionVC = self.navigationController?.viewControllers[1] as! LFPhotoCollectionVC
        collectionVC.selectedDataArray = self.selectedDataArray;
        self.navigationController?.popViewController(animated: true)
        
    }
    // MARK: UICollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (assetsFetchResults?.count)!;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LFPhotoShowBigCell", for: indexPath) as! LFPhotoShowBigCell;
        let asset = self.assetsFetchResults![indexPath.row]
        self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize, contentMode: PHImageContentMode.aspectFill, options: nil) { (image, nfo) in
            cell.photoImageView.image = image
        }
        
        return cell;
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let indexPath = NSIndexPath(item: Int(scrollView.contentOffset.x/scrollView.frame.size.width), section: 0)
        self.refreshSeletedStatus(indexPath: indexPath)
    }
    
    
    
    func showAlertOfMaxnumber()  {
        let title = "你最多只能选择\(self.maxSelected)张照片"
        let alertVC = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "知道了", style: .cancel, handler: nil);
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }


    
  
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
