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
        Query().queryOneData(urlStr: url, tableName: DatabaseTableName.discuss.rawValue, appcode: APPCODE, fieldToValueDic: ["blog_id":self.logModel.id]) {[weak self] (responseData) in
            guard let mySelf = self else {return}
            SwiftMBHUD.dismiss()
            let json = String(data: responseData, encoding: .utf8)
            if let baseDiscussModel = BaseDiscussModel.deserialize(from: json) {
                if baseDiscussModel.result?.count ?? 0 > 0 {

                    for model in baseDiscussModel.result! {
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
                                        mySelf.discussModelArr.append(model)
                                        return
                                    }

                                    let imageURL = DownloadFileURL + usermodel!.photo
                                    DBRequest.GET(url: imageURL, params: nil) {[weak self] (imageJsonData) in
                                        guard let mySelf = self else {return}
                                        model.imageData = imageJsonData
                                        mySelf.discussModelArr.append(model)

                                    } failure: { (code, message) in
                                        print("头像下载失败")
                                    }
                                } else {
                                    mySelf.discussModelArr.append(model)
                                }
                            }
                        }
                    }
                } else {
                    SwiftMBHUD.dismiss()
                }
            }
        }
    }

}
