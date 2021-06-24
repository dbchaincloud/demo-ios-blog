//
//  CreateMnemonicController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
// creat_top_image

import Foundation
import UIKit
import SwiftLeePackage

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
        mnemonicStr = SwiftLeePackage().createMnemonic()

        /// 进入首页
        contentView.goinButtonBlock = {
            UserDefault.saveCurrentMnemonic(self.mnemonicStr)
            /// 生成公钥私钥地址等保存
            let strArr :[String] = self.mnemonicStr.components(separatedBy: " ")
            let manager = DBMnemonicManager().MnemonicGetPrivateKeyStrAndPublickStrWithMnemonicArr(strArr)
            if manager.address.count > 0, manager.privateKeyString.count > 0 {
                UserDefault.saveAddress(manager.address)
                UserDefault.savePublickey(manager.publicKeyString)
                UserDefault.savePrivateKey(manager.privateKeyString)
                UserDefault.savePrivateKeyUintArr(manager.privateKeyUint)

                let vc = HomeViewController()
                let nav = BaseNavigationController.init(rootViewController: vc)
                UIApplication.shared.keyWindow?.rootViewController = nav
            } else {
                SwiftMBHUD.showText("助记词错误 无法生成公钥与私钥")
            }
        }
        /// 生成助记词
        contentView.createMnemonicBlock = {
            self.mnemonicStr = SwiftLeePackage().createMnemonic()
        }
    }

}
