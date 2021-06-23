//
//  BaseViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import Foundation
import UIKit

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

}
