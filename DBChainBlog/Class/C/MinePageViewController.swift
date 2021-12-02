//
//  MinePageViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit
//import GMChainSm2

class MinePageViewController: BaseViewController {

    lazy var contentView : MinePageView = {
        let view = MinePageView.init(frame: self.view.frame)
        return view
    }()

    var infoModel = userModel() {
        didSet {
            self.contentView.model = infoModel
        }
    }

    override func setupUI() {
        super.setupUI()

        NotificationCenter.default.addObserver(self, selector: #selector(iconImageUploadSuccessEvent), name: NSNotification.Name(rawValue: USERICONUPLOADSUCCESS), object: nil)
        view.addSubview(contentView)
        contentView.MinePageClickIndexBlock = {[weak self] (index:IndexPath) in
            guard let mySelf = self else {return}
            let model = mySelf.contentView.logModelArr[index.section]
            let vc = BlogDetailViewController()
            vc.logModel = model
            mySelf.navigationController?.pushViewController(vc, animated: true)
        }
        getCurrentUserInfo()
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

    @objc func iconImageUploadSuccessEvent(){
        self.contentView.logModelArr.removeAll()
        getCurrentUserInfo()
        let filePath = documentTools() + "/USERICONPATH"
        if FileTools.sharedInstance.isFileExisted(fileName: USERICONPATH, path: filePath) == true  {
            let fileDic = FileTools.sharedInstance.filePathsWithDirPath(path: filePath)
            do {
                let imageData = try Data(contentsOf: URL.init(fileURLWithPath: fileDic[0]))
                contentView.iconImg = UIImage(data: imageData)!
            } catch {
                contentView.iconImg = UIImage(named: "home_icon_image")!
            }
        }
    }

    @objc func settingPageClick(){
        let vc = SettingMineViewController()
        vc.userInfoModel = self.infoModel
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func getCurrentUserInfo() {
        SwiftMBHUD.showLoading()
        dbchain.queryDataByCondition(DatabaseTableName.user.rawValue,
                                     ["created_by":dbchain.address!]) { [weak self] (result) in
            guard let mySelf = self else { SwiftMBHUD.dismiss(); return}
            guard result.isjsonStyle() else { SwiftMBHUD.dismiss(); return }
            if let userModel = BaseUserModel.deserialize(from: result) {
                if userModel.result?.count ?? 0 > 0  {
                    mySelf.infoModel = userModel.result!.last!
                }
            }
            mySelf.getCurrentBlogText()
        }
    }

    func getCurrentBlogText() {
        dbchain.queryDataByCondition(DatabaseTableName.blogs.rawValue,
                                     ["created_by":dbchain.address!]) {[weak self] (result) in
            guard let mySelf = self else { SwiftMBHUD.dismiss(); return }
            guard result.isjsonStyle() else { SwiftMBHUD.dismiss(); return }
            SwiftMBHUD.dismiss()
            if let blogModel = BaseBlogsModel.deserialize(from: result) {
                if blogModel.result?.count ?? 0 > 0 {
                    mySelf.contentView.logModelArr = blogModel.result!
                } else {
                    SwiftMBHUD.dismiss()
                    print("没有发布过博客")
                }
            }
        }
    }
}
