//
//  ReleaseBlogViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit

class ReleaseBlogViewController: BaseViewController {

    lazy var blogView : ReleaseBlogView = {
        let view = ReleaseBlogView.init(frame: self.view.frame)
        return view
    }()

    override func setupUI() {
        super.setupUI()
        view.addSubview(blogView)
    }

    override func setNavBar() {
        super.setNavBar()

        let navContentView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: kNavBarHeight))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navContentView)

        let leftButton = UIButton.init(frame: CGRect(x: -4, y: 0, width: 46, height: 40))
        leftButton.titleLabel?.font = UIFont().themeHNBoldFont(size: 22)
        leftButton.setTitle("标题", for: .normal)
        leftButton.setTitleColor(.black, for: .normal)
        navContentView.addSubview(leftButton)

        let cancelBtn = UIButton.init(frame: CGRect(x: navContentView.frame.width - 76, y: 0, width: 40, height: 40))
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(.colorWithHexString("9E9E9E"), for: .normal)
        cancelBtn.titleLabel?.font = UIFont.ThemeFont.H3Regular
        cancelBtn.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        navContentView.addSubview(cancelBtn)

    }

    @objc func cancelButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
}
