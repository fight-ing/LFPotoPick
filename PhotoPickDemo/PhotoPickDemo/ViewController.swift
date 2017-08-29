//
//  ViewController.swift
//  PhotoPickDemo
//
//  Created by fei on 2017/8/28.
//  Copyright © 2017年 self. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }
    
    @IBAction func selectButtonClicked(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: "拍照", style: UIAlertActionStyle.default) { (action) in
            self.addPhotoFromCamera()
        }
        let photoAction = UIAlertAction(title: "照片库", style: UIAlertActionStyle.default) { (action) in
            self.addPhotoFromLibrary()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel) { (action) in
            
        }
        
        
        alert.addAction(cameraAction)
        alert.addAction(photoAction)
        alert.addAction(cancelAction)
        self.show(alert, sender: nil)
    }
    
    func addPhotoFromCamera()  {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        self.show(imagePicker, sender: nil)
    }
    
    func addPhotoFromLibrary()  {
        _ = self.presentLFPhotoPikcerVC(maxSelected: 5) { (assets) in
            
        }
    }
    
    // MARK: UIImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage;
        print(info);
        
        picker.dismiss(animated: true) { 
            
        };
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

