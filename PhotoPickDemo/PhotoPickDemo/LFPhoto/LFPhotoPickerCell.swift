//
//  LFPhotoPickerCell.swift
//  PhotoPickDemo
//
//  Created by fei on 2017/8/29.
//  Copyright © 2017年 self. All rights reserved.
//

import UIKit
/**
 * 相册cell
 */
class LFPhotoPickerCell: UITableViewCell {

    @IBOutlet var cellNumberLabel: UILabel!
    
    @IBOutlet var cellTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
