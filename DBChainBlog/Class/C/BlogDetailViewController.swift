//
//  BlogDetailViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit
import SwiftLeePackage

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

        contentView.BlogReplyBlock = { (titleStr: String) in
            /// 发布评论
            let publicKey = UserDefault.getPublickey()
            let publicBase = publicKey?.hexaData.base64EncodedString()

            let insert = InsertDara.init(appcode: APPCODE, publikeyBase64Str: publicBase!, address: UserDefault.getAddress()!, tableName: DatabaseTableName.discuss.rawValue, chainid: Chainid, privateKeyDataUint: UserDefault.getPrivateKeyUintArr()! as! [UInt8], baseUrl: BASEURL, publicKey: UserDefault.getPublickey()!, insertDataUrl: InsertDataURL)

            let userModelUrl = GetUserDataURL + UserDefault.getAddress()!

            SwiftMBHUD.showLoading()
            DBRequestCollection().getUserAccountNum(urlStr: userModelUrl) {[weak self] (jsonData) in
                guard let mySelf = self else {return}
                let fieldsDic = ["blog_id":mySelf.logModel.id,"discuss_id":"","text":titleStr]

                insert.insertRowSortedSignDic(model: jsonData, fields: fieldsDic) { (stateStr) in
                    print("插入数据的结果:\(stateStr)")
                    if stateStr == "1" {
                        SwiftMBHUD.showSuccess("发布成功")
                        mySelf.contentView.replyTextField.text = nil
                        mySelf.getCurrentBlogCommentList()
                    } else {
                        SwiftMBHUD.showError("发布失败")
                    }
                }
            } failure: { (code, message) in
                print("获取用户信息失败")
                SwiftMBHUD.dismiss()
            }
        }

        contentView.titleStr = logModel.title
        contentView.detailTitleStr = logModel.body
        getCurrentBlogCommentList()
    }

    /// 获取当前博客评论列表
    func getCurrentBlogCommentList() {
        SwiftMBHUD.showLoading()
        self.discussModelArr.removeAll()
        let token = DBToken().createAccessToken(privateKey: UserDefault.getPrivateKeyUintArr()! as! [UInt8], PublikeyData: (UserDefault.getPublickey()?.hexaData)!)
        let url = QueryDataUrl + "\(token)/"
        /// 临时保存回复数据
        var tempReplyArr :[discussModel] = []

        let queue = DispatchQueue(label: "myQueue")
        let group = DispatchGroup()
        let signal = DispatchSemaphore(value: 1)

        group.enter()
        queue.async {
            signal.wait()
            Query().queryOneData(urlStr: url, tableName: DatabaseTableName.discuss.rawValue, appcode: APPCODE, fieldToValueDic: ["blog_id":self.logModel.id]) {[weak self] (responseData) in
                guard let mySelf = self else {group.leave(); return}
                SwiftMBHUD.dismiss()
                let json = String(data: responseData, encoding: .utf8)
                if let baseDiscussModel = BaseDiscussModel.deserialize(from: json) {
                    if baseDiscussModel.result?.count ?? 0 > 0 {

                        for (idx,model) in baseDiscussModel.result!.enumerated() {
                            print("评论的id:\(model.id) 文章的id: \(model.blog_id)  回复评论的id:\(model.discuss_id)")

                            /// 查找User表的头像cid
                            Query().queryOneData(urlStr: url, tableName: DatabaseTableName.user.rawValue, appcode: APPCODE, fieldToValueDic: ["dbchain_key":model.created_by]) { (userData) in
                                let userJson = String(data: userData, encoding: .utf8)
                                if let userModel = BaseUserModel.deserialize(from: userJson) {
                                    if userModel.result?.count ?? 0 > 0 {
                                        /// 下载头像
                                        let usermodel = userModel.result!.last
                                        if !usermodel!.name.isBlank {
                                            model.nickName = usermodel!.name
                                        }

                                        guard !usermodel!.photo.isBlank else {
                                            if model.discuss_id.isBlank {
                                                mySelf.discussModelArr.append(model)
                                            } else {
                                                tempReplyArr.append(model)
                                            }
                                            if idx == baseDiscussModel.result!.count - 1 {
                                                signal.signal()
                                                group.leave()
                                            }
                                            return
                                        }

                                        let imageURL = DownloadFileURL + usermodel!.photo
                                        DBRequest.GET(url: imageURL, params: nil) {[weak self] (imageJsonData) in
                                            guard let mySelf = self else {return}
                                            model.imageData = imageJsonData
                                            if model.discuss_id.isBlank {
                                                mySelf.discussModelArr.append(model)
                                            } else {
                                                tempReplyArr.append(model)
                                            }

//                                            if idx == baseDiscussModel.result!.count - 1 {
////                                                print("单独评论的条数:\(mySelf.discussModelArr.count)  111回复的数量:\(tempReplyArr.count)")
//
//                                                for relpyModel in tempReplyArr {
//                                                    let rmodel = replyDiscussModel()
//                                                    rmodel.blog_id = relpyModel.blog_id
//                                                    rmodel.created_at = relpyModel.created_at
//                                                    rmodel.created_by = relpyModel.created_by
//                                                    rmodel.id = relpyModel.id
//                                                    rmodel.imageData = relpyModel.imageData
//                                                    rmodel.nickName = relpyModel.nickName
//                                                    rmodel.replyID = relpyModel.id
//                                                    rmodel.discuss_id = relpyModel.discuss_id
//                                                    rmodel.text = relpyModel.text
//
//                                                    for (index,dmodel) in mySelf.discussModelArr.enumerated() {
//                                                        if dmodel.id == relpyModel.discuss_id {
//                                                            dmodel.replyModelArr.append(rmodel)
//                                                            mySelf.discussModelArr[index] = dmodel
//                                                        }
//                                                    }
//                                                }
//                                            }
                                            if idx == baseDiscussModel.result!.count - 1 {
                                                signal.signal()
                                                group.leave()
                                            }
                                        } failure: { (code, message) in
                                            print("头像下载失败")
                                        }

                                    } else {
                                        if model.discuss_id.isBlank {
                                            mySelf.discussModelArr.append(model)
                                        } else {
                                            tempReplyArr.append(model)
                                        }

                                        if idx == baseDiscussModel.result!.count - 1 {
                                            signal.signal()
                                            group.leave()
                                        }
//                                        if idx == baseDiscussModel.result!.count - 1 {
////                                            print("单独评论的条数:\(mySelf.discussModelArr.count)  222回复的数量:\(tempReplyArr.count)")
//                                            for relpyModel in tempReplyArr {
//                                                let rmodel = replyDiscussModel()
//                                                rmodel.blog_id = relpyModel.blog_id
//                                                rmodel.created_at = relpyModel.created_at
//                                                rmodel.created_by = relpyModel.created_by
//                                                rmodel.id = relpyModel.id
//                                                rmodel.imageData = relpyModel.imageData
//                                                rmodel.nickName = relpyModel.nickName
//                                                rmodel.replyID = relpyModel.id
//                                                rmodel.discuss_id = relpyModel.discuss_id
//                                                rmodel.text = relpyModel.text
//
//                                                for (index,dmodel) in mySelf.discussModelArr.enumerated() {
//                                                    if dmodel.id == relpyModel.discuss_id {
//                                                        dmodel.replyModelArr.append(rmodel)
//                                                        mySelf.discussModelArr[index] = dmodel
//                                                    }
//                                                }
//                                            }
//                                        }
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

            print("单条评论数组: \(self.discussModelArr.count) --- 多评论数组:\(tempReplyArr.count)")
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

                for (index,dmodel) in self.discussModelArr.enumerated() {
                    if dmodel.id == relpyModel.discuss_id {
                        dmodel.discuss_id = relpyModel.discuss_id
                        dmodel.replyModelArr.append(rmodel)
                        self.discussModelArr[index] = dmodel
                    }
                }
            }

            signal.signal()
        }
    }

}
