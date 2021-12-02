//
//  CreateMnemonicController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
// creat_top_image

import Foundation
import UIKit
import DBChainKit
//import GMChainSm2
import HDWalletSDK
import DBChainSm2

class CreateMnemonicController: BaseViewController {

    lazy var contentView : CreateMnemonicView = {
        let view = CreateMnemonicView.init(frame: self.view.frame)
        return view
    }()

    var mnemonicStr :String! = "" {
        didSet {
            contentView.mnemonicStr = mnemonicStr
        }
    }

    override func setupUI() {
        super.setupUI()
        view.addSubview(contentView)

        mnemonicStr = dbchain.createMnemonic()

        /// 生成助记词
        contentView.createMnemonicBlock = {
            self.mnemonicStr = dbchain.createMnemonic()
        }

        /// 进入首页
        contentView.goinButtonBlock = {
            SwiftMBHUD.showLoading()

            UserDefault.saveCurrentMnemonic(self.mnemonicStr)
            /// 全部转小写, 大写生成私钥不一致
            let lowMnemoicStr = self.mnemonicStr.lowercased()
            let privatekey = dbchain.generatePrivateByMenemonci(lowMnemoicStr)
            let publickey = dbchain.generatePublickey(privatekey)
            let address = dbchain.generateAddress(publickey)

            print("\n\n私钥:\(privatekey)")
            print("公钥:\(publickey)")
            print("地址:\(address)")
            print("Token:\(dbchain.token)\n")

            dbchain.registerNewAccountNumber {[weak self] (state, message) in
                guard let mySelf = self else {return}
                if state == true {
                    UserDefault.saveUserNikeName(mySelf.contentView.nameTextField.text!)
                    UserDefault.saveAddress(dbchain.address!)
                    UserDefault.savePublickey(dbchain.publicKey!)
                    UserDefault.savePrivateKey(dbchain.privateKey!)

                    /// 将用户信息新增到用户表
                    let fieldsDic = ["name":mySelf.contentView.nameTextField.text!,
                                     "age":"",
                                     "dbchain_key":address,
                                     "sex":"",
                                     "status":"",
                                     "photo":"",
                                     "motto":""] as [String : Any]
                    dbchain.insertRow(tableName: DatabaseTableName.user.rawValue,
                                      fields: fieldsDic) { (result) in
                        if result == "1" {
                            SwiftMBHUD.dismiss()
                            let vc = HomeViewController()
                            let nav = BaseNavigationController.init(rootViewController: vc)
                            UIApplication.shared.keyWindow?.rootViewController = nav
                        } else {
                            SwiftMBHUD.showError("登录失败")
                        }
                    }
                } else {
                    SwiftMBHUD.showError("获取积分失败")
                }
            }
//            if address.count > 0, publicKey.count > 0 {
//                let token = Sm2Token.shared.createAccessToken(privateKeyStr: privatekeyStr, publikeyStr: publicKey)
//                IPAProvider.request(NetworkAPI.getIntegralUrl(token: token)) { [weak self] (result) in
//                    guard let mySelf = self else {return}
//                    guard case .success(let response) = result else { SwiftMBHUD.showError("获取积分失败");return }
//                    let jsonStr = String(data: response.data, encoding: .utf8)
//                    if String().isjsonStyle(txt: jsonStr!) {
//                        let dic : [String : Any] = (jsonStr?.toDictionary())!
//                        guard !dic.keys.contains("error") else { SwiftMBHUD.showError("请求错误"); return }
//                        if dic["result"] as! String == "success" {
//                            print("获取积分成功!!!")
//                            UserDefault.saveUserNikeName(mySelf.contentView.nameTextField.text!)
//                            UserDefault.saveAddress(address)
//                            UserDefault.savePublickey(publicKey)
//                            UserDefault.savePrivateKey(privatekeyStr)
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                            mySelf.insertUserInfo(address: address, publicKey: publicKey, privateKey: privatekeyStr)
//                            }
//                        } else { SwiftMBHUD.showError("获取积分失败") }
//                    }
//                }
//            } else {
//                SwiftMBHUD.showText("助记词错误 无法生成公钥与私钥")
//            }
        }
    }


//    func insertUserInfo(address: String,publicKey: String, privateKey: String) {
//        IPAProvider.request(NetworkAPI.getUserModelUrl(address: address)) {[weak self] (userResult) in
//            guard let mySelf = self else {return}
//            guard case .success(let userResponse) = userResult else { SwiftMBHUD.showError("获取用户信息失败");return }
//            do {
//                let model = try JSONDecoder().decode(ChainUserModel.self, from: userResponse.data)
//                let fieldsDic = ["name":mySelf.contentView.nameTextField.text!,
//                                 "age":"",
//                                 "dbchain_key":address,
//                                 "sex":"",
//                                 "status":"",
//                                 "photo":"",
//                                 "motto":""] as [String : Any]
//                IPAProvider.request(NetworkAPI.insertData(userModel: model, fields: fieldsDic, tableName: DatabaseTableName.user.rawValue, publicKey: publicKey, privateKey: privateKey, address: address, msgType: insertDataType, sm2UserID: sm2UserID)) { (insertResult) in
//
//                    guard case .success(let insertResponse) = insertResult else { return }
//                    do {
//                        print("获取用户信息: \(String(data: insertResponse.data, encoding: .utf8)!)")
//                        let model = try JSONDecoder().decode(BaseInsertModel.self, from: insertResponse.data)
//                        guard model.txhash != nil else {return}
//
//                        /// 查询结果
//                        print("开始查询结果: 公钥:\(publicKey)\n私钥:\(privateKey)\n")
//                        loopQueryResultState(publickeyStr: publicKey, privateKey: privateKey, queryTxhash: model.txhash!) { (state) in
//                            if state == true {
//                                SwiftMBHUD.dismiss()
//                                let vc = HomeViewController()
//                                let nav = BaseNavigationController.init(rootViewController: vc)
//                                UIApplication.shared.keyWindow?.rootViewController = nav
//                            } else {
//                                SwiftMBHUD.showError("登录失败")
//                            }
//                        }
//                    } catch { print("插入信息错误") }
//                }
//            } catch {
//                SwiftMBHUD.dismiss()
//            }
//        }
//    }

}
