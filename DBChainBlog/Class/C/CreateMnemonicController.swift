//
//  CreateMnemonicController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
// creat_top_image

import Foundation
import UIKit
import DBChainKit
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

            dbchain.registerNewAccountNumber {[weak self] (state, message) in
                guard let mySelf = self else {return}
                if state == true {
                    UserDefault.saveUserNikeName(mySelf.contentView.nameTextField.text!)
                    UserDefault.saveAddress(address)
                    UserDefault.savePublickey(privatekey)
                    UserDefault.savePrivateKey(publickey)

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
        }
    }
}
