//
//  BaseViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import Foundation
import UIKit
import DBChainKit

/// 初始化DBChainKit
let dbchain = DBChainKit.init(appcode: "5APTSCPSF7",
                              chainid: "testnet",
                              baseurl: "https://controlpanel.dbchain.cloud/relay/",
                              encryptType: Sm2())

class BaseViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true)
    }

    override func viewDidLoad() {
        super .viewDidLoad()
        self.view.backgroundColor = .colorWithHexString("F3F3F3")
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        setNavBar()
        setupUI()
    }

    public func setupUI() {

    }

    public func setNavBar(){

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
