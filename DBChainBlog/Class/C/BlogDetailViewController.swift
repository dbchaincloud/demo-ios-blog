//
//  BlogDetailViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit
import DBChainKit

class BlogDetailViewController: BaseViewController {

    lazy var contentView : BlogDetailView = {
        let view = BlogDetailView.init(frame: self.view.frame)
        return view
    }()

    var logModel = blogModel()
    var discussModelArr = [discussModel]() {
        didSet {
            self.contentView.discussModelArr = discussModelArr
        }
    }

    override func setupUI() {
        super.setupUI()
        self.title = "帖子详情"
        self.view.addSubview(contentView)

        contentView.BlogReplyBlock = {[weak self] (titleStr: String, replyID: String ) in
            guard let mySelf = self else {return}
            mySelf.replyTitle(withTitle: titleStr, withReplyId: replyID)
        }

        contentView.titleStr = logModel.title
        contentView.detailTitleStr = logModel.body
        getCurrentBlogCommentList()
    }


    /// 发布评论
    func replyTitle(withTitle titleStr: String,withReplyId replyid:String) {
        /// 发布评论
//        let insert = InsertRequest.init(tableName: DatabaseTableName.discuss.rawValue, insertDataUrl: InsertDataURL)
        let insert = Sm2InsertNetwork.init(tableName: DatabaseTableName.discuss.rawValue, insertDataUrl: InsertDataURL)
        let userModelUrl = GetUserDataURL + UserDefault.getAddress()!
        SwiftMBHUD.showLoading()
        DBRequestCollection().getUserAccountNum(urlStr: userModelUrl) {[weak self] (jsonData) in
            guard let mySelf = self else {return}
            let fieldsDic = ["blog_id":mySelf.logModel.id,"discuss_id":replyid,"text":titleStr]

            insert.sm2_insertRowSortedSignDic(model: jsonData, fields: fieldsDic) { (stateStr) in
                if stateStr == "1" {
                    SwiftMBHUD.showSuccess("发布成功")
                    mySelf.contentView.replyTextField.text = nil
                    mySelf.getCurrentBlogCommentList()
                } else {
                    SwiftMBHUD.showError("发布失败")
                }
            }
        } failure: { (code, message) in
            SwiftMBHUD.dismiss()
        }
    }


    /// 获取当前博客评论列表
    func getCurrentBlogCommentList() {
        SwiftMBHUD.showLoading()
        self.discussModelArr.removeAll()
//        let token = DBToken().createAccessToken(privateKey: UserDefault.getPrivateKeyUintArr()! , PublikeyData: (UserDefault.getPublickey()?.hexaData)!)
        let token = Sm2Token().createAccessToken(privateKey: UserDefault.getPrivateKey()!, PublikeyData: UserDefault.getPublickey()!.hexaData)
        let url = QueryDataUrl + "\(token)/"
        /// 临时保存回复数据
        var tempReplyArr :[discussModel] = []

        let queue = DispatchQueue(label: "myQueue")
        let group = DispatchGroup()
        let signal = DispatchSemaphore(value: 1)

        group.enter()
        queue.async {
            signal.wait()
            DBQuery().queryOneData(urlStr: url, tableName: DatabaseTableName.discuss.rawValue, appcode: APPCODE, fieldToValueDic: ["blog_id":self.logModel.id]) {[weak self] (responseData) in
                guard let mySelf = self else {group.leave(); return}
                let json = String(data: responseData, encoding: .utf8)
                if let baseDiscussModel = BaseDiscussModel.deserialize(from: json) {
                    if baseDiscussModel.result?.count ?? 0 > 0 {

                        for (idx,model) in baseDiscussModel.result!.enumerated() {
                            /// 查找User表的头像cid   QmTpgJnPzkq1ist8CCT3cUFijd6STL2JjnwHzCMYNfR6sW
                            DBQuery().queryOneData(urlStr: url, tableName: DatabaseTableName.user.rawValue, appcode: APPCODE, fieldToValueDic: ["dbchain_key":model.created_by]) { (userData) in
                                let userJson = String(data: userData, encoding: .utf8)
                                if let userModel = BaseUserModel.deserialize(from: userJson) {
                                    if userModel.result?.count ?? 0 > 0 {
                                        /// 下载头像
                                        let usermodel = userModel.result!.last
                                        if !usermodel!.name.isBlank {
                                            model.nickName = usermodel!.name
                                        }

                                        if !usermodel!.photo.isBlank {
                                            /// 判断本地是否有数据
                                            let dicPath = documentTools() + "/\(usermodel!.photo)"
                                            if FileTools.sharedInstance.isFileExisted(fileName: usermodel!.photo, path: dicPath) == true {
                                                /// 本地有缓存数据.
                                                /// 该文件已存在
                                                let fileDic = FileTools.sharedInstance.filePathsWithDirPath(path: dicPath)
                                                let imageData = try! Data(contentsOf: URL.init(fileURLWithPath: fileDic[0]))
                                                model.imageData = imageData

                                                if model.discuss_id.isBlank {
                                                    mySelf.discussModelArr.append(model)
                                                } else {
                                                    model.replyNickName = usermodel!.name
                                                    tempReplyArr.append(model)
                                                }

                                                if idx == baseDiscussModel.result!.count - 1 {
                                                    signal.signal()
                                                    group.leave()
                                                }
                                            } else {
                                                let imageURL = DownloadFileURL + usermodel!.photo
                                                DBRequest.GET(url: imageURL, params: nil) {[weak self] (imageJsonData) in
                                                    guard let mySelf = self else {return}
                                                    model.imageData = imageJsonData
                                                    if model.discuss_id.isBlank {
                                                        mySelf.discussModelArr.append(model)
                                                    } else {
                                                        model.replyNickName = usermodel!.name
                                                        tempReplyArr.append(model)
                                                    }
                                                    if idx == baseDiscussModel.result!.count - 1 {
                                                        signal.signal()
                                                        group.leave()
                                                    }
                                                } failure: { (code, message) in
                                                    print("头像下载失败")
                                                    if idx == baseDiscussModel.result!.count - 1 {
                                                        signal.signal()
                                                        group.leave()
                                                    }
                                                }
                                            }

                                        } else {
                                            if model.discuss_id.isBlank {
                                                mySelf.discussModelArr.append(model)
                                            } else {
                                                model.replyNickName = usermodel!.name
                                                tempReplyArr.append(model)
                                            }
                                            if idx == baseDiscussModel.result!.count - 1 {
                                                signal.signal()
                                                group.leave()
                                            }
                                        }

                                    } else {
                                        if model.discuss_id.isBlank {
                                            mySelf.discussModelArr.append(model)
                                        } else {
                                            model.replyNickName = "未知用户"
                                            tempReplyArr.append(model)
                                        }

                                        if idx == baseDiscussModel.result!.count - 1 {
                                            signal.signal()
                                            group.leave()
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        signal.signal()
                        group.leave()
                        SwiftMBHUD.dismiss()
                    }
                }
            }
        }

        group.enter()
        queue.async {
            signal.wait()
            DispatchQueue.main.async {
                SwiftMBHUD.dismiss()
                var tempModelArr = self.discussModelArr
                for relpyModel in tempReplyArr {
                    let rmodel = replyDiscussModel()
                    rmodel.blog_id = relpyModel.blog_id
                    rmodel.created_at = relpyModel.created_at
                    rmodel.created_by = relpyModel.created_by
                    rmodel.id = relpyModel.id
                    rmodel.imageData = relpyModel.imageData
                    rmodel.nickName = relpyModel.nickName
                    rmodel.replyID = relpyModel.id
                    rmodel.discuss_id = relpyModel.discuss_id
                    rmodel.text = relpyModel.text

                    for (index,dmodel) in tempModelArr.enumerated() {
                        if dmodel.id == relpyModel.discuss_id {
                            rmodel.replyNickName = dmodel.nickName
                            dmodel.discuss_id = relpyModel.discuss_id
                            dmodel.replyModelArr.append(rmodel)
                            tempModelArr[index] = dmodel
                        }
                    }
                }

                self.discussModelArr = tempModelArr
            }
            signal.signal()
        }
    }

}
