//
//  CameraView.swift
//
//  Created by Paris on 2022/7/1.
//

import UIKit
import AVFoundation

class CameraView: UIView, AVCapturePhotoCaptureDelegate {
    
    //捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
    var device:AVCaptureDevice?
    //AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
    var input:AVCaptureDeviceInput?
    //当启动摄像头开始捕获输入
    var ImageOutPut:AVCapturePhotoOutput?
    //session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
    var  session:AVCaptureSession?
    //图像预览层，实时显示捕获的图像
    var previewLayer:AVCaptureVideoPreviewLayer?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        if (canUserCamear()) {
            customCamera()
        }
    }
    
    //相机权限
    func canUserCamear() -> Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if(authStatus == AVAuthorizationStatus.denied){
            let alertController = UIAlertController(title: " 请打开相机权限", message: "设置-隐私-相机", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (UIAlertAction) in
            }
            let okAction = UIAlertAction(title: "确定", style: .default) { (UIAlertAction) in
                let url = URL(string: UIApplication.openSettingsURLString)!
                if (UIApplication.shared.canOpenURL(url)){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            //此处跳转
            //RouterManager.navigator.present(alertController)
            return false
        }
        return true
    }
    
    //相机初始化
    func customCamera()  {
        //  使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
        self.device = AVCaptureDevice.default(for: AVMediaType.video)
        //使用设备初始化输入
        do {
             self.input = try AVCaptureDeviceInput(device: self.device!)
        }catch {
            print(error)
            return
        }
        //生成输出对象
        self.ImageOutPut = AVCapturePhotoOutput()
        //生成会话，用来结合输入输出
        self.session = AVCaptureSession.init()
        if((self.session?.canSetSessionPreset(AVCaptureSession.Preset.hd1920x1080))!){
            self.session?.sessionPreset = AVCaptureSession.Preset.hd1920x1080;

        }
        if(self.session!.canAddInput(self.input!)){
            self.session!.addInput(self.input!)
        }
        
        if(self.session!.canAddOutput(self.ImageOutPut!)){
            self.session!.addOutput(self.ImageOutPut!)
        }
        
            //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
        self.previewLayer = AVCaptureVideoPreviewLayer.init(session: session!)
        self.previewLayer?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - 5)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.layer.insertSublayer(self.previewLayer!, at: 0)
        
            //开始启动
        self.session?.startRunning()
        do{
            if(try self.device?.lockForConfiguration() ==  nil && self.device!.isFlashModeSupported(AVCaptureDevice.FlashMode.auto)){
                self.device?.flashMode = AVCaptureDevice.FlashMode.auto
                self.device?.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus

            }
        }catch{
            print(error)
        }
        
            //自动白平衡
        if(self.device!.isWhiteBalanceModeSupported(AVCaptureDevice.WhiteBalanceMode.autoWhiteBalance)){
            self.device?.whiteBalanceMode = AVCaptureDevice.WhiteBalanceMode.autoWhiteBalance
        }else{
            self.device?.unlockForConfiguration()
        }

    }
    
    private var _callBack:((_ image:UIImage)->Void)!
    func cameraCut(callBack:@escaping ((_ image:UIImage)->Void)){
        _callBack = callBack
        ImageOutPut!.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if (error != nil) {return}
        
        // 使用该方式获取图片，可能图片会存在旋转问题，在使用的时候调整图片即可
        let data = photo.fileDataRepresentation()
        let image = UIImage(data: data!)!
        var originImage = fixOrientation(image: image) //拍出来的照片需旋转90度
        
        let width = originImage.size.width
        let height = width * (9/16)
        let top = (originImage.size.height - height) / 2
        
        var scaledImageRect = CGRect.zero
        scaledImageRect.size.width  = width
        scaledImageRect.size.height = height
        scaledImageRect.origin.x    = 0
        scaledImageRect.origin.y    = top
        
        originImage = imageFromImage(image: originImage, rect: scaledImageRect)
        if (_callBack != nil) {
            _callBack(originImage)
        }
        print(1)
    }
    
    
    /// 对原图进旋转校准
    /// - Parameter image: orginImage
    /// - Returns: image
    func fixOrientation(image:UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }
        
        var transform = CGAffineTransform.identity
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: .pi)
            break
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
            
        default:
            break
        }
        
        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
            
        default:
            break
        }
        
        let ctx = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
        
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(image.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(image.size.height), height: CGFloat(image.size.width)))
            break
            
        default:
            ctx?.draw(image.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(image.size.width), height: CGFloat(image.size.height)))
            break
        }
        
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
        
        return img
    }
    
    /**
     *从图片中按指定的位置大小截取图片的一部分
     * UIImage image 原始的图片
     * CGRect rect 要截取的区域
     */
    func imageFromImage(image:UIImage,rect:CGRect) -> UIImage {
        //将UIImage转换成CGImageRef
        let sourceImageRef = image.cgImage
         //按照给定的矩形区域进行剪裁
        let newImageRef = sourceImageRef?.cropping(to: rect)
        let newImage =  UIImage.init(cgImage: newImageRef!)
        return newImage
    }
}
