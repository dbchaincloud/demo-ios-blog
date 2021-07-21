//
//  HomeListViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import UIKit
import DBChainKit
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
        let token = DBToken().createAccessToken(privateKey: UserDefault.getPrivateKeyUintArr()! as! [UInt8], PublikeyData: (UserDefault.getPublickey()?.hexaData)!)

        let url = QueryDataUrl + "\(token)/"

        Query().queryTableData(urlStr: url, tableName: DatabaseTableName.blogs.rawValue, appcode: APPCODE) {[weak self] (status) in
            guard let mySelf = self else {return}

            if let bmodel = BaseBlogsModel.deserialize(from: status) {
                if bmodel.result?.count ?? 0 > 0 {
                    let signal = DispatchSemaphore(value: 1)

                    let global = DispatchGroup()
                    var tempBlogArr :[blogModel] = []

                    for (index,model) in bmodel.result!.enumerated() {
                        global.notify(queue: DispatchQueue.global(), work: DispatchWorkItem.init(block: {
                            signal.wait()
                            model.readNumber = mySelf.randomIn(min: 100, max: 1000)

                            /// Token 时效原因, 数据过多时会导致后面数据获取失败,  Token 需要重新生成
                            let userToken = DBToken().createAccessToken(privateKey: UserDefault.getPrivateKeyUintArr()! as! [UInt8], PublikeyData: (UserDefault.getPublickey()?.hexaData)!)
                            let UserUrl = QueryDataUrl + "\(userToken)/"

                            /// 查询头像
                            Query().queryOneData(urlStr: UserUrl, tableName: DatabaseTableName.user.rawValue, appcode: APPCODE, fieldToValueDic: ["dbchain_key":model.created_by]) { (responseData) in

                                let json = String(data: responseData, encoding: .utf8)
                                if let umodel = BaseUserModel.deserialize(from: json) {
                                    if umodel.result?.count ?? 0 > 0 {
                                        /// 下载头像
                                        let userLastModel = umodel.result?.last
                                        model.name = userLastModel!.name
                                        if !userLastModel!.photo.isBlank {
                                            let dicPath = documentTools() + "/\(userLastModel!.photo)"
                                            if FileTools.sharedInstance.isFileExisted(fileName: userLastModel!.photo, path: dicPath) == true {
                                                /// 该文件已存在
                                                let fileDic = FileTools.sharedInstance.filePathsWithDirPath(path: dicPath)
                                                let imageData = try! Data(contentsOf: URL.init(fileURLWithPath: fileDic[0]))
                                                model.imgdata = imageData
                                                tempBlogArr.append(model)
                                                signal.signal()
                                            } else {
                                                /// 下载图片
                                                let imageURL = DownloadFileURL + userLastModel!.photo

                                                DBRequest.GET(url: imageURL, params: nil) {[weak self] (imageJsonData) in
                                                    guard let mySelf = self else {return}
                                                    /// 创建目录 文件夹 缓存数据
                                                    let isSuccess = FileTools.sharedInstance.createDirectory(path:dicPath)
                                                    /// 创建文件并保存
                                                    if isSuccess {
                                                        let saveFileStatus = FileTools.sharedInstance.createFile(fileName: userLastModel!.photo, path: dicPath, contents: imageJsonData, attributes: nil)
                                                        if saveFileStatus == true {
                                                            /// 该文件已存在
                                                            let fileDic = FileTools.sharedInstance.filePathsWithDirPath(path: dicPath)
                                                            print("保存成功!!!! \(fileDic[0])")

                                                        } else {
                                                            print("保存失败!!!! \(userLastModel?.name)")
                                                        }
                                                    }
                                                    model.imgdata = imageJsonData
                                                    tempBlogArr.append(model)
                                                    print("下载头像成功的下标:\(index) 下载头像的用户昵称: \(userLastModel!.name)")
                                                    signal.signal()
                                                } failure: { (code, message) in
                                                    tempBlogArr.append(model)
                                                    signal.signal()
                                                }
                                            }
                                        } else {
                                            print("没有头像的下标: \(index)")
                                            tempBlogArr.append(model)
                                            signal.signal()
                                        }
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
                                    print("头像全部下载完毕!!!!!!!!!")
                                    mySelf.modelArr = tempBlogArr
                                    SwiftMBHUD.dismiss()
                                }
                            }
                        }))
                    }

                } else {
                    /// 没有博客数据
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
