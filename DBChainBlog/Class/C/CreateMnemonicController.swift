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

    var mnemonicStr :String! = ""{
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
            let vc = HomeViewController()
            let nav = BaseNavigationController.init(rootViewController: vc)
            UIApplication.shared.keyWindow?.rootViewController = nav
        }
        /// 生成助记词
        contentView.createMnemonicBlock = {
            self.mnemonicStr = SwiftLeePackage().createMnemonic()
        }
    }

}
