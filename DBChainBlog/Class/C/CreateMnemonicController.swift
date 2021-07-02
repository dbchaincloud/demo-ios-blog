//
//  CreateMnemonicController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
// creat_top_image

import Foundation
import UIKit
import DBChainKit

class CreateMnemonicController: BaseViewController {

    lazy var contentView : CreateMnemonicView = {
        let view = CreateMnemonicView.init(frame: self.view.frame)
        return view
    }()

    var mnemonicStr :String! = "" {
        didSet{
            contentView.mnemonicStr = mnemonicStr
        }
    }

    override func setupUI() {
        super.setupUI()

        view.addSubview(contentView)

        mnemonicStr = DBChainKit().createMnemonic()

        /// 生成助记词
        contentView.createMnemonicBlock = {
            self.mnemonicStr = DBChainKit().createMnemonic()
        }

        /// 进入首页
        contentView.goinButtonBlock = {
            SwiftMBHUD.showLoading()

            UserDefault.saveCurrentMnemonic(self.mnemonicStr)

            /// 生成公钥私钥地址等保存
            let strArr :[String] = self.mnemonicStr.components(separatedBy: " ")
            let manager = DBMnemonicManager().MnemonicGetPrivateKeyStrAndPublickStrWithMnemonicArr(strArr)

            if manager.address.count > 0, manager.privateKeyString.count > 0 {

                let token = DBToken().createAccessToken(privateKey: manager.privateKeyUint , PublikeyData: manager.publicKeyString.hexaData)

                let url = GetIntegralUrl + token

                DBRequest.GET(url: url, params: nil) { [weak self] (responeData) in
                    guard let mySelf = self else {return}
                    let jsonStr = String(data: responeData, encoding: .utf8)
                    if String().isjsonStyle(txt: jsonStr!) {
                        let dic : [String : Any] = (jsonStr?.toDictionary())!
                        if dic["result"] as! String == "success" {
                            UserDefault.saveUserNikeName(mySelf.contentView.nameTextField.text!)
                            UserDefault.saveAddress(manager.address)
                            UserDefault.savePublickey(manager.publicKeyString)
                            UserDefault.savePrivateKey(manager.privateKeyString)
                            UserDefault.savePrivateKeyUintArr(manager.privateKeyUint)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                /// 更新个人信息
                                let publicBase = manager.publicKeyString.hexaData.base64EncodedString()
                                let insert = InsertDara.init(appcode: APPCODE,
                                                             publikeyBase64Str: publicBase,
                                                             address: manager.address,
                                                             tableName: DatabaseTableName.user.rawValue,
                                                             chainid: Chainid,
                                                             privateKeyDataUint: manager.privateKeyUint,
                                                             baseUrl: BASEURL,
                                                             publicKey: manager.publicKeyString,
                                                             insertDataUrl: InsertDataURL)
                                
                                let userModelUrl = GetUserDataURL + UserDefault.getAddress()!
                                DBRequestCollection().getUserAccountNum(urlStr: userModelUrl) { (userModel) in

                                    let fieldsDic = ["name":mySelf.contentView.nameTextField.text!,
                                                     "age":"",
                                                     "dbchain_key":manager.address,
                                                     "sex":"",
                                                     "status":"",
                                                     "photo":"",
                                                     "motto":""] as [String : Any]

                                    insert.insertRowSortedSignDic(model: userModel, fields: fieldsDic) { (stateStr) in
                                        if stateStr == "1" {
                                            SwiftMBHUD.dismiss()
                                            let vc = HomeViewController()
                                            let nav = BaseNavigationController.init(rootViewController: vc)
                                            UIApplication.shared.keyWindow?.rootViewController = nav

                                        } else {
                                            SwiftMBHUD.showError("登录失败")
                                        }
                                    }
                                } failure: { (code, message) in
                                    print("获取用户信息失败")
                                    SwiftMBHUD.dismiss()
                                }
                            }

                        } else { SwiftMBHUD.showError("获取积分失败") }
                    }
                } failure: { (code, message) in
                    print("获取新用户积分失败")
                    SwiftMBHUD.showError("获取积分失败")
                }

            } else {
                SwiftMBHUD.showText("助记词错误 无法生成公钥与私钥")
            }
        }

    }

}
