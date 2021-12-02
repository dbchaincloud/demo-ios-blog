//
//  BlogDetailViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit
//import GMChainSm2

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
        SwiftMBHUD.showLoading()
        let dic = ["blog_id":self.logModel.id,
                   "discuss_id":replyid,
                   "text":titleStr]
        dbchain.insertRow(tableName: DatabaseTableName.discuss.rawValue,
                          fields: dic) { (result) in
            guard result == "1" else { SwiftMBHUD.showError("发布失败"); return }
            SwiftMBHUD.showSuccess("发布成功")
            self.contentView.replyTextField.text = nil
            self.getCurrentBlogCommentList()
        }
    }


    /// 获取当前博客评论列表
    func getCurrentBlogCommentList() {
        SwiftMBHUD.showLoading()
        self.discussModelArr.removeAll()

        /// 临时保存回复数据
        var tempReplyArr :[discussModel] = []

        let queue = DispatchQueue(label: "myQueue")
        let group = DispatchGroup()
        let signal = DispatchSemaphore(value: 1)

        group.enter()
        queue.async {
            signal.wait()
            dbchain.queryDataByCondition(DatabaseTableName.discuss.rawValue,
                                         ["blog_id":self.logModel.id]) { [weak self] (result) in

                guard let mySelf = self else { group.leave(); SwiftMBHUD.dismiss(); return }
                guard result.isjsonStyle() else { group.leave(); SwiftMBHUD.dismiss(); return }

                guard let baseDiscussModel = BaseDiscussModel.deserialize(from: result) else {
                    signal.signal()
                    group.leave()
                    SwiftMBHUD.dismiss()
                    return
                }

                guard baseDiscussModel.result?.count ?? 0 > 0 else {
                    signal.signal()
                    group.leave()
                    SwiftMBHUD.dismiss()
                    return
                }

                for (idx,model) in baseDiscussModel.result!.enumerated() {
                    print("查询评论的头像: \(model.id) --- 评论id: \(model.discuss_id) --- 内容:\(model.text) -- \(model.created_by)")
                    /// 查找User表的头像cid   QmTpgJnPzkq1ist8CCT3cUFijd6STL2JjnwHzCMYNfR6sW
                    dbchain.queryDataByCondition( DatabaseTableName.user.rawValue,
                                                  ["dbchain_key":model.created_by]) { (cidResult) in

                        guard cidResult.isjsonStyle() else { return }
                        guard let userModel = BaseUserModel.deserialize(from: cidResult) else {
                            signal.signal()
                            group.leave()
                            return
                        }

                        if userModel.result?.count ?? 0 > 0 {
                            /// 头像
                            let usermodel = userModel.result!.last
                            if !usermodel!.name.isBlank {
                                model.nickName = usermodel!.name
                            }

                            model.imageIndex = usermodel!.photo
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
//                    rmodel.imageData = relpyModel.imageData
                    rmodel.imageIndex = relpyModel.imageIndex
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
