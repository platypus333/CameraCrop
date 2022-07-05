//
//  PetEnterViewController.swift
//
//  Created by Paris on 2022/6/30.
//

import Foundation
import UIKit

class PetEnterViewController:UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photosButton: UIButton!
    @IBOutlet weak var cameraMaskView: CameraMaskView!
    @IBOutlet weak var cameraView: CameraView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cameraCut(_ sender: Any) {
        cameraView.cameraCut { image in
            
        }
    }
    
    var takingPicture:UIImagePickerController!
    @IBAction func goPhotoLibary(_ sender: Any) {
        takingPicture =  UIImagePickerController()
        takingPicture.sourceType = .photoLibrary
        //是否截取，设置为true在获取图片后可以将其截取成正方形
        takingPicture.allowsEditing = true
        takingPicture.delegate = self
        present(takingPicture, animated: true, completion: nil)
    }
    
    
    //拍照或是相册选择返回的图片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        takingPicture.dismiss(animated: true, completion: nil)
        var newHeadImage:UIImage?
        //截图
        newHeadImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if (newHeadImage != nil) {
            let width = newHeadImage!.size.width
            let height = width * (9/16)
            let top = (width - height) / 2
            let newImage = imageFromImage(image: newHeadImage!, rect: CGRect(x: 0, y: top, width: width, height: height))
        }
    }
    
    func imageFromImage(image:UIImage,rect:CGRect) -> UIImage {
        //将UIImage转换成CGImageRef
        let sourceImageRef = image.cgImage
         //按照给定的矩形区域进行剪裁
        let newImageRef = sourceImageRef?.cropping(to: rect)
        let newImage =  UIImage.init(cgImage: newImageRef!)
        return newImage
    }
}
