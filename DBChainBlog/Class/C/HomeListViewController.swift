//
//  HomeListViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import UIKit
import GMChainSm2

class HomeListViewController: BaseViewController {

    var modelArr:[blogModel] = [] {
        didSet {
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

        NotificationCenter.default.addObserver(self, selector: #selector(getHomeBlogListData), name: NSNotification.Name.init(rawValue: BLOGSUPLOADSUCCESS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getHomeBlogListData), name: NSNotification.Name(rawValue: USERICONUPLOADSUCCESS), object: nil)

        getHomeBlogListData()
        view.addSubview(contentView)

        contentView.HomeListDidSelectIndexBlock = { [weak self] (index: IndexPath) in
            guard let mySelf = self else {return}
            let model = mySelf.modelArr[index.section]
            let vc = BlogDetailViewController()
            vc.logModel = model
            mySelf.navigationController?.pushViewController(vc, animated: true)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    @objc func getHomeBlogListData() {

        SwiftMBHUD.showLoading()
        self.modelArr.removeAll()
        guard UserDefault.getPrivateKey() != nil,UserDefault.getPublickey() != nil else {
            return
        }
        print(":私钥:\(UserDefault.getPrivateKey()!)")
        print(":公钥:\(UserDefault.getPublickey()!)")
        let token = Sm2Token.shared.createAccessToken(privateKeyStr: UserDefault.getPrivateKey()!, publikeyStr: UserDefault.getPublickey()!)
        IPAProvider.request(NetworkAPI.queryTableList(token: token, tableName: DatabaseTableName.blogs.rawValue, appcode: APPCODE)) {[weak self] (result) in
            guard let mySelf = self else {return}
            guard case .success(let response) = result else { return }
            do {
                let json = try response.mapJSON() as! NSDictionary
                if let bmodel = BaseBlogsModel.deserialize(from: json) {
                if bmodel.result?.count ?? 0 > 0 {
                    let signal = DispatchSemaphore(value: 1)
                    let global = DispatchGroup()
                    var tempBlogArr :[blogModel] = []

                    for (index,model) in bmodel.result!.enumerated() {
                        global.notify(queue: DispatchQueue.global(), work: DispatchWorkItem.init(block: {
                            signal.wait()
                            model.readNumber = mySelf.randomIn(min: 100, max: 1000)
                            /// Token 时效原因, 数据过多时会导致后面数据获取失败,  Token 需要重新生成
                            let userToken = Sm2Token.shared.createAccessToken(privateKeyStr: UserDefault.getPrivateKey()!, publikeyStr: UserDefault.getPublickey()!)
                            IPAProvider.request(NetworkAPI.queryOneData(token: userToken, tableName: DatabaseTableName.user.rawValue, appcode: APPCODE, fieldDic: ["dbchain_key":model.created_by])) { (userResult) in
                                guard case .success(let userResponse) = userResult else { return }
                                let userJson = String(data: userResponse.data, encoding: .utf8)
                                if let umodel = BaseUserModel.deserialize(from: userJson) {
                                    if umodel.result?.count ?? 0 > 0 {
                                        /// 下载头像
                                        let userLastModel = umodel.result?.last
                                        model.name = userLastModel!.name
                                        model.imgUrl = userLastModel?.photo
                                        tempBlogArr.append(model)
                                        signal.signal()
                                    } else {
                                        print("没有查询到用户信息的下标: \(index) -- 博客标题: \(model.name)")
                                        tempBlogArr.append(model)
                                        signal.signal()
                                    }
                                } else {
                                    tempBlogArr.append(model)
                                    signal.signal()
                                }

                                if index == bmodel.result!.count - 1 {
                                    mySelf.modelArr = tempBlogArr.reversed()
                                    SwiftMBHUD.dismiss()
                                }
                            }
                        }))
                    }
                } else {
                    /// 没有博客数据
                    SwiftMBHUD.dismiss()
                }

                }
            } catch { print("返回结果解析 JSON 失败! ") }
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
