//
//  MinePageViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit

class MinePageViewController: BaseViewController {

    lazy var contentView : MinePageView = {
        let view = MinePageView.init(frame: self.view.frame)
        return view
    }()

    override func setupUI() {
        super.setupUI()
        view.addSubview(contentView)
    }

    override func setNavBar() {
        super.setNavBar()
        let navImgV = UIImageView.init(frame: CGRect(x: SCREEN_WIDTH * 0.5 - 90, y: kStatusBarHeight, width: 180, height: 40))
        navImgV.image = UIImage(named: "homepage_nav_image")
        self.navigationItem.titleView = navImgV

        let editBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        editBtn.setImage(UIImage(named: "homepage_edit"), for: .normal)
        editBtn.addTarget(self, action: #selector(settingPageClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: editBtn)
    }

    @objc func settingPageClick(){
        let vc = SettingMineViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
