//
//  HomeListViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import UIKit
//import GMChainSm2

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
        dbchain.queryDataByTablaName(DatabaseTableName.blogs.rawValue) {[weak self] (result) in
            guard let mySelf = self else { SwiftMBHUD.dismiss(); return }
            guard result.isjsonStyle() else { SwiftMBHUD.dismiss(); return }
            if let bmodel = BaseBlogsModel.deserialize(from: result) {
            if bmodel.result?.count ?? 0 > 0 {

                let signal = DispatchSemaphore(value: 1)
                let global = DispatchGroup()
                var tempBlogArr :[blogModel] = []

                for (index,model) in bmodel.result!.enumerated() {
                    global.notify(queue: DispatchQueue.global(), work: DispatchWorkItem.init(block: {
                        signal.wait()
                        model.readNumber = mySelf.randomIn(min: 100, max: 1000)
                        /// 查询头像信息
                        dbchain.queryDataByCondition(DatabaseTableName.user.rawValue,
                                                     ["dbchain_key":model.created_by]) { (userResult) in

                            guard userResult.isjsonStyle() else { SwiftMBHUD.dismiss(); return }
                            if let umodel = BaseUserModel.deserialize(from: userResult) {
                                if umodel.result?.count ?? 0 > 0 {
                                    /// 查找头像
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
