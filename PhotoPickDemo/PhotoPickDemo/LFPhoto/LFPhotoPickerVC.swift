//
//  LFPhotoPickerVC.swift
//  PhotoPickDemo
//
//  Created by fei on 2017/8/29.
//  Copyright © 2017年 self. All rights reserved.
//

import UIKit
import Photos
/**
 *  选择相册
 */

struct LFPhotoAlbumItem {
    
    //相簿标题
    var title:String?
    
    //相簿内容
    var albumResult:PHFetchResult<PHAsset>
}

class LFPhotoPickerVC: UIViewController,UITableViewDataSource,UITableViewDelegate {

    
    
    @IBOutlet var tableView: UITableView!
    //相册列表
    var albumItemsArray:[LFPhotoAlbumItem] = []
    
    //最多可选照片数
    var maxSelected:Int = Int.max
    
    //照片选择完成之后回调
    var completeHandle:((_ assets:[PHAsset]) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        PHPhotoLibrary.requestAuthorization { (status) in
            if status != .authorized {
                return ;
            }
            
            //列出所有系统的智能相册
            let smartOptions = PHFetchOptions();
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: smartOptions);
            
            self.convertCollection(collection: smartAlbums)
            
            //列出所有用户创建的相册
            let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil);
            self.convertCollection(collection: userCollections as! PHFetchResult<PHAssetCollection>);
            //相册所包含的照片数量排序
            self.albumItemsArray.sort(by: { (item1, item2) -> Bool in
                return item1.albumResult.count > item2.albumResult.count;
            })

            //异步加载表格数据，需要在主线程中调用reloadData()方法
            DispatchQueue.main.async {
                self.tableView.reloadData();
                
                if let photoCollectionVC = self.storyboard?.instantiateViewController(withIdentifier: "LFPhotoCollectionVC") as? LFPhotoCollectionVC {
                    photoCollectionVC.title = self.albumItemsArray.first?.title;
                    photoCollectionVC.assetsFetchResults = self.albumItemsArray.first?.albumResult;
                    photoCollectionVC.completeHandle = self.completeHandle;
                    photoCollectionVC.maxSelected = self.maxSelected;
                    
                    self.navigationController?.pushViewController(photoCollectionVC, animated: false)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "相簿"
        let rightBarItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = rightBarItem
    }
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func convertCollection(collection:PHFetchResult<PHAssetCollection>) {
        for i in 0..<collection.count {
            //获取当前相册所有照片
            let resultOptions = PHFetchOptions()
            resultOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)];
            
            resultOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            
            let c = collection[i]
            let assetsFetchResult = PHAsset.fetchAssets(in: c, options: resultOptions)
            
            //没有图片的空相簿不显示
            if assetsFetchResult.count > 0 {
                let title = titleOfAlbumForChinse(title: c.localizedTitle)
                albumItemsArray.append(LFPhotoAlbumItem(title: title, albumResult: assetsFetchResult))
            }
            
        }
    }
    //由于系统返回的相册集名称为英文，我们需要转换为中文
    private func titleOfAlbumForChinse(title:String?) -> String? {
        if title == "Slo-mo" {
            return "慢动作"
        } else if title == "Recently Added" {
            return "最近添加"
        } else if title == "Favorites" {
            return "个人收藏"
        } else if title == "Recently Deleted" {
            return "最近删除"
        } else if title == "Videos" {
            return "视频"
        } else if title == "All Photos" {
            return "所有照片"
        } else if title == "Selfies" {
            return "自拍"
        } else if title == "Screenshots" {
            return "屏幕快照"
        } else if title == "Camera Roll" {
            return "相机胶卷"
        }
        return title
    }

    
    //MARK: UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumItemsArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LFPhotoPickerCell") as! LFPhotoPickerCell
        let item = self.albumItemsArray[indexPath.row]
        cell.cellTitleLabel.text = "\(item.title ?? "")"
        cell.cellNumberLabel.text = "(\(item.albumResult.count))张"
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.albumItemsArray[indexPath.row]
        let photoCollectionVC = self.storyboard?.instantiateViewController(withIdentifier: "LFPhotoCollectionVC") as! LFPhotoCollectionVC
        photoCollectionVC.title = item.title;
        photoCollectionVC.assetsFetchResults = item.albumResult;
        photoCollectionVC.completeHandle = self.completeHandle;
        photoCollectionVC.maxSelected = self.maxSelected;
        
        self.navigationController?.pushViewController(photoCollectionVC, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIViewController {
    //LFPhotoPickerVC提供外部调用的接口，用于显示图片选择页面
    func presentLFPhotoPikcerVC(maxSelected:Int=Int.max,completeHandler:((_ assets:[PHAsset])->())?) -> LFPhotoPickerVC? {
        if let vc = UIStoryboard(name: "LFPhoto", bundle: Bundle.main).instantiateViewController(withIdentifier: "LFPhotoPickerVC") as? LFPhotoPickerVC {
            
            //完成回调
            vc.completeHandle = completeHandler;
            
            //最大可选照片数量
            vc.maxSelected = maxSelected;
            
            let navigationVC = UINavigationController(rootViewController: vc)
            self.present(navigationVC, animated: true, completion: nil)
            
            return vc;
        }
        return nil;
    }
}


