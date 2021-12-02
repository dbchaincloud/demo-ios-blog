//
//  SettingMineViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit
//import GMChainSm2
import Alamofire

class SettingMineViewController: BaseViewController {

    lazy var contentView : SettingMineView = {
        let view = SettingMineView.init(frame: self.view.frame)
        return view
    }()

    // MARK: 图片选择器界面
    var imagePicker: UIImagePickerController = UIImagePickerController()

    var selectUploadImage = UIImage() {
        didSet {
            contentView.iconImage = selectUploadImage
        }
    }

    var userInfoModel = userModel()

    override func setupUI() {
        super.setupUI()

        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        view.addSubview(contentView)
        contentView.umodel = userInfoModel

        contentView.settingIconImageViewBlock = { [weak self] in
            guard let mySelf = self else {return}
            let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            controller.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil)) // 取消按钮
            controller.addAction(UIAlertAction(title: "拍照选择", style: .default) { action in
                mySelf.selectorSourceType(type: .camera)
            }) // 拍照选择
            controller.addAction(UIAlertAction(title: "相册选择", style: .default) { action in
                mySelf.selectorSourceType(type: .photoLibrary)
            }) // 相册选择
            mySelf.present(controller, animated: true, completion: nil)
        }

        contentView.settingSaveBlock = {[weak self] (nameStr:String,sex:String,age:String,mottoStr:String) in
            guard let mySelf = self else {return}
            SwiftMBHUD.showLoading()
            if mySelf.selectUploadImage.pngData() != nil {
                /// 上传头像
                mySelf.uploadUserIconGetResultString(imageName: nameStr) { (result) in

                    if !result.isEmpty {
                        mySelf.uploadUserInfoEvent(result, nameStr, sex, age, mottoStr)
                    } else {
                        SwiftMBHUD.showError("头像上传失败,请重试")
                    }
                }

            } else {
                /// 判断数据是否有修改
                if mySelf.userInfoModel.age == age,mySelf.userInfoModel.name == nameStr,mySelf.userInfoModel.sex == sex,mySelf.userInfoModel.motto == mottoStr {
                    SwiftMBHUD.dismiss()
                    mySelf.navigationController?.popViewController(animated: true)
                } else {
                    /// 数据有修改
                    if mySelf.userInfoModel.photo.isEmpty {
                        mySelf.uploadUserInfoEvent("", nameStr, sex, age, mottoStr)
                    } else {
                        mySelf.uploadUserInfoEvent(mySelf.userInfoModel.photo,nameStr, sex, age, mottoStr)
                    }
                }
            }
        }
    }

    func uploadUserInfoEvent(_ resultCid:String,_ nameStr:String,_ sex:String,_ age:String,_ mottoStr:String) {
        /// 插入user表
        let dic = ["name":nameStr,
                   "age":age,
                   "dbchain_key":dbchain.address!,
                   "sex":sex,
                   "status":"",
                   "photo":resultCid,
                   "motto":mottoStr]

        dbchain.insertRow(tableName: DatabaseTableName.user.rawValue,
                          fields: dic) { [weak self] (result) in
            guard let mySelf = self else { SwiftMBHUD.dismiss(); return }
            if result == "1" {
                SwiftMBHUD.showSuccess("保存成功")
                mySelf.savePngData()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: USERICONUPLOADSUCCESS), object: nil)
                mySelf.navigationController?.popViewController(animated: true)
            } else {
                SwiftMBHUD.showError("保存失败")
            }
        }
    }

    func savePngData() {
        if self.selectUploadImage.pngData() != nil {
            /// 将头像保存到本地
            let filePath = documentTools() + "/USERICONPATH"
            let imageData = self.selectUploadImage.pngData()!

            /// 创建文件并保存
            if FileTools.sharedInstance.isFileExisted(fileName: USERICONPATH, path: filePath) == true {
                /// 该文件已存在
                // 删除
                let _ = FileTools.sharedInstance.deleteFile(fileName: USERICONPATH, path: filePath)
            } else {
                /// 重新创建目录 文件夹 缓存数据
                let _ = FileTools.sharedInstance.createDirectory(path:filePath)
            }

            /// 创建文件并保存
            if FileTools.sharedInstance.isFileExisted(path: filePath) {
                let saveFileStatus = FileTools.sharedInstance.createFile(fileName: USERICONPATH, path: filePath, contents:imageData, attributes: nil)
                if saveFileStatus == true {
                    print("图片保存成功")
                } else {
                    print("图片保存失败")
                }
            }
        }
    }

    func uploadUserIconGetResultString(imageName:String,resultStrBlock:@escaping(_ resultStr : String) -> Void) {

        let url = dbchain.baseurl! + "dbchain/upload/\(dbchain.token!)/\(dbchain.appcode!)"

        let headers : HTTPHeaders = ["Content-type": "multipart/form-data",
                                     "Content-Disposition" : "form-data",
                                     "Content-Type": "application/json;charset=utf-8"]
        /// 压缩图片
        let imgData = self.selectUploadImage.compressImage()
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append(imgData, withName: "file", fileName: imageName, mimeType: "application/octet-stream")
        }, to: url,headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                let value = response.value as? Dictionary<String, Any>
                if ((value?.keys.contains("result")) != nil) {
                    resultStrBlock(value!["result"] as! String)
                } else {
                    resultStrBlock("")
                }

            } else {
                resultStrBlock("")
            }
        }
    }


    func selectorSourceType(type: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) {
            imagePicker.sourceType = type
            // 打开图片选择器
            present(imagePicker, animated: true, completion: nil)
        } else {
            if type == .camera {
                SwiftMBHUD.showError("相机权限未打开")
            } else {
                SwiftMBHUD.showError("相册权限未打开")
            }
        }
      }

    override func setNavBar() {
        super.setNavBar()
        let navImgV = UIImageView.init(frame: CGRect(x: SCREEN_WIDTH * 0.5 - 90, y: kStatusBarHeight, width: 180, height: 40))
        navImgV.image = UIImage(named: "setting_infomation")
        self.navigationItem.titleView = navImgV
    }
    
}


extension SettingMineViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    // MARK: - Image picker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /// 5. 用户选中一张图片时触发这个方法，返回关于选中图片的 info
        /// 6. 获取这张图片中的 originImage 属性，就是图片自己
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("error: did not picked a photo")
        }

        /// 7. 根据须要作其它相关操做，这里选中图片之后关闭 picker controller 便可
        picker.dismiss(animated: true) { [unowned self] in
            // add a image view on self.view
            self.selectUploadImage = selectedImage
        }
    }


      // MARK: 当点击图片选择器中的取消按钮时回调
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
      }

}


extension UIImage {
    //图片压缩逻辑
    public func compressImage() -> Data{
        let imageSize = self.jpegData(compressionQuality: 1)!.count/1024
        var myImage = self
        if imageSize < 500{
            //如果小于500k,直接上传
            return myImage.jpegData(compressionQuality: 1)!
        }else{
            //取短边
            let width = myImage.size.width > myImage.size.height ? myImage.size.height:myImage.size.width
            if width <= 1080{
                //大于500k短边小于1080，直接上传
                return myImage.jpegData(compressionQuality: 1)!
            }else{
                //待压缩的Size
                let size: CGSize?
                //如果宽大于高
                if myImage.size.width > myImage.size.height{
                    size = CGSize.init(width: myImage.size.width*(1080/myImage.size.height), height: 1080)
                }else{
                    size = CGSize.init(width: 1080, height: myImage.size.height*(1080/myImage.size.width))
                }
                //尺寸压缩
                UIGraphicsBeginImageContext(size!)
                myImage.draw(in: CGRect.init(x: 0, y: 0, width: size!.width, height: size!.height))
                myImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()

                if myImage.jpegData(compressionQuality: 1)!.count/1024 >= 500{
                    //尺寸压缩后还大于500k
                    for index in 1...5{
                        let rate = CGFloat(1) - 0.1*CGFloat(index)
                        let count = myImage.jpegData(compressionQuality: rate)!.count/1024
                        if count <= 500{
                            return myImage.jpegData(compressionQuality: rate)!
                        }
                        //系数0.5仍然大于500k上传
                        if index == 5{
                            return myImage.jpegData(compressionQuality: rate)!
                        }
                    }
                } else {
                    //尺寸压缩后还小于500k

                    return myImage.jpegData(compressionQuality: 1)!
                }
            }
        }
        return myImage.jpegData(compressionQuality: 1)!
    }
}
