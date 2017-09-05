//
//  LFPhotoCollectionVC.swift
//  PhotoPickDemo
//
//  Created by fei on 2017/8/29.
//  Copyright © 2017年 self. All rights reserved.
//

import UIKit
import Photos
/**
 *  展示相册照片
 */
class LFPhotoCollectionVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,LFPhotoCollectionCellDelegate {

    
    @IBOutlet var bottomView: UIView!
    
    var completeButton:LFCompleteButton!
    
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let scale = UIScreen.main.scale
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        assetGridThumbnailSize = CGSize(width: cellSize.width*scale, height: cellSize.height*scale)
        collectionView.reloadData()
        completeButton.num = selectedDataArray.count;
        if selectedDataArray.count > 0 {
            completeButton.isEnabled = true;
        } else {
            completeButton.isEnabled = false;
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化和重置缓存
        self.imageManager = PHCachingImageManager()
        self.resetCachedAssets()
        
        //设置单元格尺寸
        let layout = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout);
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width/4-1, height: UIScreen.main.bounds.size.width/4-1);
        layout.minimumLineSpacing = 1;
        layout.minimumInteritemSpacing = 1;
        
        let rightBarItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel));
        self.navigationItem.rightBarButtonItem = rightBarItem;
        
        completeButton = LFCompleteButton()
        completeButton.addTarget(target: self, action: #selector(completeButtonClicked))
        completeButton.center = CGPoint(x: UIScreen.main.bounds.size.width - 35, y: bottomView.frame.size.height/2)
        completeButton.isEnabled = self.selectedDataArray.count != 0
        bottomView.addSubview(completeButton)
    }
    
    //重置缓存
    func resetCachedAssets(){
        self.imageManager.stopCachingImagesForAllAssets()
    }
    func cancel(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func completeButtonClicked() {
        
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
        });
    }
    
    // MARK: UICollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (assetsFetchResults?.count)!;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LFPhotoCollectionCell", for: indexPath) as! LFPhotoCollectionCell;
        if (self.assetsFetchResults?.count)! <= indexPath.row {
            return cell;
        }
        let asset = self.assetsFetchResults![indexPath.row]
        self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize, contentMode: PHImageContentMode.aspectFill, options: nil) { (image, nfo) in
            cell.photoImageView.image = image
        }
        if selectedDataArray.index(of: indexPath as NSIndexPath) != nil {
            cell.checkStatus = true
        } else {
            cell.checkStatus = false
        }
        cell.delegate = self;
        return cell;
    }
    
    // MARK: UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bigVC = self.storyboard?.instantiateViewController(withIdentifier: "LFPhotoShowBigVC") as! LFPhotoShowBigVC
        
        bigVC.completeHandle = self.completeHandle;
        bigVC.assetsFetchResults = self.assetsFetchResults;
        bigVC.selectedDataArray = self.selectedDataArray;
        bigVC.maxSelected = self.maxSelected;
        bigVC.currentIndex = indexPath as NSIndexPath;
        self.navigationController?.pushViewController(bigVC, animated: true)
    }
    
    // MARK: LFPhotoCollectionCell Delegate
    func lfPhottCollectionCellDidSelect(_ cell: LFPhotoCollectionCell) {
        if selectedDataArray.count < maxSelected {
            let indexPath = collectionView.indexPath(for: cell);
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
            let indexPath = collectionView.indexPath(for: cell);
            if let i = selectedDataArray.index(of: indexPath! as NSIndexPath) {
                selectedDataArray.remove(at: i)
                if selectedDataArray.count > 0 && !self.completeButton.isEnabled {
                    completeButton.isEnabled = true;
                }
            } else {
                showAlertOfMaxnumber()
                cell.checkStatus = false;
            }
        } else {
            showAlertOfMaxnumber()
            cell.checkStatus = false;
            
        }
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
