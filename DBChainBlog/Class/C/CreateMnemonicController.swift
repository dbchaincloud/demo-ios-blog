//
//  CreateMnemonicController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
// creat_top_image

import Foundation
import UIKit
import DBChainKit
import DBChainSm2

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
//            let mnemonicArr :[String] = self.mnemonicStr.components(separatedBy: " ")
//            let manager = DBMnemonicManager().MnemonicGetPrivateKeyStrAndPublickStrWithMnemonicArr(mnemonicArr)
//
//            let tempStr = mnemonicArr.joined(separator: ",")
//            let tempMnemoicStr = tempStr.replacingOccurrences(of: ",", with: " ")

            
            let lowMnemoicStr = self.mnemonicStr.lowercased()
            let seedBip39 = Mnemonic.createSeed(mnemonic: lowMnemoicStr)
            let privateKey = PrivateKey(seed: seedBip39, coin: .bitcoin)
            // 生成 Sm2 公钥
            let publicKey = DBChainGMSm2Utils.adoptPrivatekeyGetPublicKey(privateKey.raw.toHexString(), isCompress: true)
            // 生成 dbchain 地址
            let sm2Publick = DBChainGMUtils.hex(toData: publicKey)
            let sm2Pub = publicKey.hexaData
            let address = Sm2Address().sm2GetPubToDpAddress(publicKey.hexaData, .DBCHAIN_MAIN)

            print("sm2Hex: \(sm2Publick), \nhex: \(sm2Pub), \naddress:\(address)")

            if address.count > 0, publicKey.count > 0 {
                let token = Sm2Token().createAccessToken(privateKey: privateKey.raw.toHexString(), PublikeyData: sm2Publick!)
                print("VVVV: token: \(token)")
                let url = GetIntegralUrl + token

                DBRequest.GET(url: url, params: nil) { [weak self] (responeData) in
                    guard let mySelf = self else {return}
                    let jsonStr = String(data: responeData, encoding: .utf8)
                    print("首次进入获取用户信息: \(jsonStr)")
                    if String().isjsonStyle(txt: jsonStr!) {
                        let dic : [String : Any] = (jsonStr?.toDictionary())!
                        if dic["result"] as! String == "success" {
                            UserDefault.saveUserNikeName(mySelf.contentView.nameTextField.text!)
                            UserDefault.saveAddress(address)
                            UserDefault.savePublickey(publicKey)
                            UserDefault.savePrivateKey(privateKey.raw.toHexString())
//                            UserDefault.savePrivateKeyUintArr(manager.privateKeyUint)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                /// 更新个人信息
//                                let publicBase = manager.publicKeyString.hexaData.base64EncodedString()
//                                let insert = InsertDara.init(appcode: APPCODE,
//                                                             publikeyBase64Str: publicBase,
//                                                             address: manager.address,
//                                                             tableName: DatabaseTableName.user.rawValue,
//                                                             chainid: Chainid,
//                                                             privateKeyDataUint: manager.privateKeyUint,
//                                                             baseUrl: BASEURL,
//                                                             publicKey: manager.publicKeyString,
//                                                             insertDataUrl: InsertDataURL)

//                                let insert = InsertRequest.init(tableName: DatabaseTableName.user.rawValue, insertDataUrl: InsertDataURL)

                                let insert = Sm2InsertNetwork.init(tableName: DatabaseTableName.user.rawValue, insertDataUrl: InsertDataURL)

                                let userModelUrl = GetUserDataURL + UserDefault.getAddress()!

                                DBRequestCollection().getUserAccountNum(urlStr: userModelUrl) { (userModel) in

                                    let fieldsDic = ["name":mySelf.contentView.nameTextField.text!,
                                                     "age":"",
                                                     "dbchain_key":address,
                                                     "sex":"",
                                                     "status":"",
                                                     "photo":"",
                                                     "motto":""] as [String : Any]

                                    insert.sm2_insertRowSortedSignDic(model: userModel, fields: fieldsDic) { (stateStr) in
                                        print("登录成功!!!!!!!! ")
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
