//
//  SettingMineViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit

class SettingMineViewController: BaseViewController {

    lazy var contentView : SettingMineView = {
        let view = SettingMineView.init(frame: self.view.frame)
        return view
    }()

    override func setupUI() {
        super.setupUI()
        view.addSubview(contentView)
    }

    override func setNavBar() {
        super.setNavBar()
        let navImgV = UIImageView.init(frame: CGRect(x: SCREEN_WIDTH * 0.5 - 90, y: kStatusBarHeight, width: 180, height: 40))
        navImgV.image = UIImage(named: "setting_infomation")
        self.navigationItem.titleView = navImgV
    }
}
