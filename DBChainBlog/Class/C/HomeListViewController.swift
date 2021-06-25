//
//  HomeListViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import UIKit
import SwiftLeePackage
class HomeListViewController: BaseViewController {

    var modelArr:[blogModel] = [] {
        didSet{
            self.contentView.modelArr = modelArr
        }
    }
    
    lazy var contentView : HomeListView = {
        let view = HomeListView.init(frame: self.view.frame)
        return view
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func setupUI() {
        super.setupUI()

        NotificationCenter.default.addObserver(self, selector: #selector(getHomeBlogListData), name: NSNotification.Name.init(rawValue: "BLOGSUPLOADSUCCESS"), object: nil)

        getHomeBlogListData()
        view.addSubview(contentView)

        contentView.HomeListDidSelectIndexBlock = { (index: IndexPath) in
            let vc = BlogDetailViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func getHomeBlogListData() {

        SwiftMBHUD.showLoading()
        self.modelArr.removeAll()
        let token = DBToken().createAccessToken(privateKey: UserDefault.getPrivateKeyUintArr()! as! [UInt8], PublikeyData: (UserDefault.getPublickey()?.hexaData)!)

        let url = QueryDataUrl + "\(token)/"
        Query().queryTableData(urlStr: url, tableName: DatabaseTableName.blogs.rawValue, appcode: APPCODE) {[weak self] (status) in
            guard let mySelf = self else {return}

            if let bmodel = BaseBlogsModel.deserialize(from: status) {
                
                if bmodel.result?.count ?? 0 > 0 {
                    for (index,model) in bmodel.result!.enumerated() {
                        model.readNumber = mySelf.randomIn(min: 100, max: 1000)
                        /// 查询头像
                        Query().queryOneData(urlStr: url, tableName: DatabaseTableName.user.rawValue, appcode: APPCODE, fieldToValueDic: ["dbchain_key":model.created_by]) { (responseData) in
                            if index == bmodel.result!.count - 1 {
                                SwiftMBHUD.dismiss()
                            }
                            let json = String(data: responseData, encoding: .utf8)
                            if let umodel = BaseUserModel.deserialize(from: json) {
                                if umodel.result?.count ?? 0 > 0 {
                                    /// 下载头像
                                    let userLastModel = umodel.result?.last
                                    model.name = userLastModel!.name
                                    guard !userLastModel!.photo.isBlank else {
                                        mySelf.modelArr.append(model)
                                        return
                                    }

                                    let imageURL = DownloadFileURL + userLastModel!.photo
                                    DBRequest.GET(url: imageURL, params: nil) {[weak self] (imageJsonData) in
                                        guard let mySelf = self else {return}
                                        model.imgdata = imageJsonData
                                        mySelf.modelArr.append(model)

                                    } failure: { (code, message) in
                                        print("头像下载失败")
                                    }

                                } else {
                                    mySelf.modelArr.append(model)
                                }
                            } else {
                                print("查询头像失败")
                                mySelf.modelArr.append(model)
                            }
                        }
                    }

                } else {
                    /// 没有博客数据
                    print("没有博客数据")
                    SwiftMBHUD.dismiss()
                }
            } else {
                SwiftMBHUD.showError("数据解析错误")
            }
        }
    }

    // 随机数
    func randomIn(min: Int, max: Int) -> Int {
        return Int(arc4random()) % (max - min + 1) + min
    }
}

extension HomeListViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
