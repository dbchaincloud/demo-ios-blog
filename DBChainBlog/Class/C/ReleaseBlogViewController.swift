//
//  ReleaseBlogViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit
import SwiftLeePackage
class ReleaseBlogViewController: BaseViewController {

    lazy var blogView : ReleaseBlogView = {
        let view = ReleaseBlogView.init(frame: self.view.frame)
        return view
    }()

    override func setupUI() {
        super.setupUI()
        view.addSubview(blogView)

        blogView.saveBlogBlock = { (titleStr: String, blogStr:String) in
            /// 插入到博客表
            let publicKey = UserDefault.getPublickey()
            let publicBase = publicKey?.hexaData.base64EncodedString()

            let insert = InsertDara.init(appcode: APPCODE, publikeyBase64Str: publicBase!, address: UserDefault.getAddress()!, tableName: DatabaseTableName.blogs.rawValue, chainid: Chainid, privateKeyDataUint: UserDefault.getPrivateKeyUintArr()! as! [UInt8], baseUrl: BASEURL, publicKey: UserDefault.getPublickey()!, insertDataUrl: InsertDataURL)

            let userModelUrl = GetUserDataURL + UserDefault.getAddress()!

            DBRequestCollection().getUserAccountNum(urlStr: userModelUrl) {[weak self] (jsonData) in
                guard let mySelf = self else {return}
                let fieldsDic = ["title":titleStr,"body":blogStr,"img":""]

                insert.insertRowSortedSignDic(model: jsonData, fields: fieldsDic) { (stateStr) in
                    print("插入数据的结果:\(stateStr)")
                    if stateStr == "1" {
                        SwiftMBHUD.showSuccess("发布成功")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BLOGSUPLOADSUCCESS"), object: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            mySelf.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        SwiftMBHUD.showError("发布失败")
                    }
                }
            } failure: { (code, message) in
                print("获取用户信息失败")
                SwiftMBHUD.dismiss()
            }
        }
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
