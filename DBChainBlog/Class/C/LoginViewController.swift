//
//  LoginViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import UIKit
//import DBChainKit
class LoginViewController: BaseViewController {

    lazy var loginView : LoginView = {
        let view = LoginView.init(frame: self.view.frame)
        return view
    }()

    override func setupUI() {
        super.setupUI()
        view.addSubview(loginView)
        loginView.goinBlock = {
            /// 记录数据重新给dbchain各参数赋值
            let privatekey = dbchain.generatePrivateByMenemonci(UserDefault.getCurrentMnemonic()!)
            let publickey = dbchain.generatePublickey(privatekey)
            _ = dbchain.generateAddress(publickey)

            let vc = HomeViewController()
            let nav = BaseNavigationController.init(rootViewController: vc)
            UIApplication.shared.keyWindow?.rootViewController = nav
        }

        loginView.signOutBlock = {
            let filePath = documentTools() + "/USERICONPATH"
            /// 创建文件并保存
            if FileTools.sharedInstance.isFileExisted(fileName: USERICONPATH, path: filePath) == true {
                /// 该文件已存在
                // 删除
                let _ = FileTools.sharedInstance.deleteFile(fileName: USERICONPATH, path: filePath)
            }
            UserDefault.removeUserData()

            let vc = CreateMnemonicController()
            let nav = BaseNavigationController.init(rootViewController: vc)
            UIApplication.shared.keyWindow?.rootViewController = nav
        }
    }
}
