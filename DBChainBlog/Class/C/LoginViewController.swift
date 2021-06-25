//
//  LoginViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import UIKit

class LoginViewController: BaseViewController {

    lazy var loginView : LoginView = {
        let view = LoginView.init(frame: self.view.frame)
        return view
    }()

    override func setupUI() {
        super.setupUI()
        view.addSubview(loginView)
        loginView.goinBlock = {
            let vc = HomeViewController()
            let nav = BaseNavigationController.init(rootViewController: vc)
            UIApplication.shared.keyWindow?.rootViewController = nav
        }

        loginView.signOutBlock = {
            let vc = CreateMnemonicController()
            let nav = BaseNavigationController.init(rootViewController: vc)
            UIApplication.shared.keyWindow?.rootViewController = nav
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
