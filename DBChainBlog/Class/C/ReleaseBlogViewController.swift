//
//  ReleaseBlogViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit
import GMChainSm2

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
            IPAProvider.request(NetworkAPI.getUserModelUrl(address: UserDefault.getAddress()!)) {[weak self] (result) in
                guard let mySelf = self else {return}
                guard case .success(let response) = result else { return }
                do {
                    let model = try JSONDecoder().decode(ChainUserModel.self, from: response.data)
                    /// 插入数据
                    let fieldsDic = ["title":titleStr,"body":blogStr,"img":""]
                    IPAProvider.request(NetworkAPI.insertData(userModel: model, fields: fieldsDic, tableName: DatabaseTableName.blogs.rawValue, publicKey: UserDefault.getPublickey()!, privateKey: UserDefault.getPrivateKey()!, address: UserDefault.getAddress()!, msgType: insertDataType, sm2UserID: sm2UserID)) { (insertResult) in
                        guard case .success(let insertResponse) = insertResult else { return }
                        do {
                            let insertModel = try JSONDecoder().decode(BaseInsertModel.self, from: insertResponse.data)
                            guard insertModel.txhash != nil else {return}
                            /// 查询结果
                            loopQueryResultState(publickeyStr: UserDefault.getPublickey()!, privateKey: UserDefault.getPrivateKey()!, queryTxhash: insertModel.txhash!) { (state) in
                                if state == true {
                                    SwiftMBHUD.showSuccess("发布成功")
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: BLOGSUPLOADSUCCESS), object: nil)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        mySelf.navigationController?.popViewController(animated: true)
                                    }
                                } else {
                                    SwiftMBHUD.showError("登录失败")
                                }
                            }

                        } catch {print("插入数据解析json失败")}
                    }
                } catch {
                    print("获取用户模型解析失败")
                }

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
