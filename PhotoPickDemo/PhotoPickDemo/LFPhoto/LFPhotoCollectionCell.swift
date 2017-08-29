//
//  LFPhotoCollectionCell.swift
//  PhotoPickDemo
//
//  Created by fei on 2017/8/29.
//  Copyright © 2017年 self. All rights reserved.
//

import UIKit

open class LFPhotoCollectionCell: UICollectionViewCell {
    
    var delegate:LFPhotoCollectionCellDelegate?
    
    @IBOutlet var checkButton: UIButton!
    
    @IBOutlet var photoImageView: UIImageView!
    
    //选择状态
    open var checkStatus:Bool? {
        didSet{
            if checkStatus! { //选中
                checkButton.setImage(UIImage.init(named: "check_yes"), for: UIControlState.normal)
            } else { //未选中
                checkButton.setImage(UIImage.init(named: "check_no"), for: UIControlState.normal)
            }
            
        }
    };
    
    
    
    @IBAction func checkButtonClicked(_ sender: UIButton) {
        checkStatus = !checkStatus!
        delegate?.lfPhottCollectionCellDidSelect(self)
        playANimate()
        
    }
    
    func playANimate()  {
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .allowUserInteraction, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                self.checkButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4, animations: {
                self.checkButton.transform = CGAffineTransform.identity
            })
            
            
        }) { (finished) in
            
        }
    }
    
}


public protocol LFPhotoCollectionCellDelegate:NSObjectProtocol {
    func lfPhottCollectionCellDidSelect(_ cell:LFPhotoCollectionCell)
}


