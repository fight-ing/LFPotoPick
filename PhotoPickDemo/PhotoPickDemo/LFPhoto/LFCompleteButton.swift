//
//  LFCompleteButton.swift
//  PhotoPickDemo
//
//  Created by fei on 2017/8/29.
//  Copyright © 2017年 self. All rights reserved.
//

import UIKit

/**
 *  完成钮，显示选择数量
 */

class LFCompleteButton: UIView {
    
    //已选数量
    var numberLabel:UILabel!
    //“完成”
    var titleLabel:UILabel!

    //默认尺寸
    let defaultFrame = CGRect(x: 0, y: 0, width: 70, height: 20)
    
    //默认文字颜色，数字背景色
    var titleColor = UIColor(red: 0x09/255, green: 0xbb/255, blue: 0x07/255, alpha: 1)
    
    var tapSingle:UITapGestureRecognizer!
    
    var num:Int = 0 {
        didSet{
            if num == 0 {
                numberLabel.isHidden = true
            } else {
                numberLabel.isHidden = false
                numberLabel.text = "\(num)"
                self.playAnimate()
            }
        }
    }
    
    var isEnabled:Bool = true{
        didSet{
            if isEnabled {
                titleLabel.textColor = titleColor;
                tapSingle.isEnabled = true;
            } else {
                titleLabel.textColor = UIColor.lightGray;
                tapSingle.isEnabled = false;
            }
        }
    }
    
    init() {
        super.init(frame: defaultFrame)
        
        //
        numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20));
        numberLabel.backgroundColor = titleColor;
        numberLabel.clipsToBounds = true;
        numberLabel.layer.cornerRadius = 10;
        numberLabel.layer.masksToBounds = true;
        numberLabel.textAlignment = .center;
        numberLabel.font = UIFont.systemFont(ofSize: 15);
        numberLabel.textColor = UIColor.white;
        numberLabel.isHidden = true;
        self.addSubview(numberLabel);
        
        titleLabel = UILabel(frame: CGRect(x: 20, y: 0, width: 50, height: 20));
        titleLabel.text = "完成";
        titleLabel.textAlignment = .center;
        titleLabel.font = UIFont.systemFont(ofSize: 15);
        titleLabel.textColor = titleColor;
        self.addSubview(titleLabel);
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    //用户数字改变时播放的动画
    func playAnimate() {
        //从小变大，且有弹性效果
        self.numberLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5, options: UIViewAnimationOptions(),
                       animations: {
                        self.numberLabel.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    //添加事件响应
    func addTarget(target: Any?, action: Selector?) {
        //单击监听
        tapSingle = UITapGestureRecognizer(target:target,action:action)
        tapSingle!.numberOfTapsRequired = 1
        tapSingle!.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapSingle!)
    }
    
}
