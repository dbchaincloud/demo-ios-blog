//
//  BlogDetailViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit
import GMChainSm2

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
        IPAProvider.request(NetworkAPI.getUserModelUrl(address: UserDefault.getAddress()!)) { [weak self] (result) in
            guard let mySelf = self else {return}
            guard case .success(let response) = result else { SwiftMBHUD.dismiss(); return }
            do {
                let model = try JSONDecoder().decode(ChainUserModel.self, from: response.data)
                let dic = ["blog_id":mySelf.logModel.id,"discuss_id":replyid,"text":titleStr]
                IPAProvider.request(NetworkAPI.insertData(userModel: model, fields: dic, tableName: DatabaseTableName.discuss.rawValue, publicKey: UserDefault.getPublickey()!, privateKey: UserDefault.getPrivateKey()!, address: UserDefault.getAddress()!, msgType: insertDataType, sm2UserID: sm2UserID)) { (insertResult) in
                    guard case .success(let insertResponse) = insertResult else {SwiftMBHUD.dismiss(); return }
                    do {
                        let imodel = try JSONDecoder().decode(BaseInsertModel.self, from: insertResponse.data)
                        guard imodel.txhash != nil else {return}
                        /// 查询结果是否成功
                        loopQueryResultState(publickeyStr: UserDefault.getPublickey()!, privateKey: UserDefault.getPrivateKey()!, queryTxhash: imodel.txhash!) { (state) in
                            if state == true {
                               SwiftMBHUD.showSuccess("发布成功")
                               mySelf.contentView.replyTextField.text = nil
                               mySelf.getCurrentBlogCommentList()
                            } else {
                                SwiftMBHUD.showError("发布失败")
                            }
                        }
                    } catch {print("11解析插入信息模型失败1")}
                }
            } catch {print("22解析用户信息失败!")}
        }
    }


    /// 获取当前博客评论列表
    func getCurrentBlogCommentList() {
        SwiftMBHUD.showLoading()
        self.discussModelArr.removeAll()
        let token = Sm2Token.shared.createAccessToken(privateKeyStr: UserDefault.getPrivateKey()!, publikeyStr: UserDefault.getPublickey()!)
        /// 临时保存回复数据
        var tempReplyArr :[discussModel] = []

        let queue = DispatchQueue(label: "myQueue")
        let group = DispatchGroup()
        let signal = DispatchSemaphore(value: 1)

        group.enter()
        queue.async {
            signal.wait()
            IPAProvider.request(NetworkAPI.queryOneData(token: token, tableName: DatabaseTableName.discuss.rawValue, appcode: APPCODE, fieldDic: ["blog_id":self.logModel.id])) {[weak self] (result) in
                guard let mySelf = self else {group.leave(); return}
                guard case .success(let response) = result else { SwiftMBHUD.dismiss(); return }
                let json = String(data: response.data, encoding: .utf8)
//                print("获取博客详情 JSON: \(json)")
                if let baseDiscussModel = BaseDiscussModel.deserialize(from: json) {
                    if baseDiscussModel.result?.count ?? 0 > 0 {
//                        print("查询博客信息")
                        for (idx,model) in baseDiscussModel.result!.enumerated() {
//                            print("开始查询 评论和回复!!!!!!!!!")
                            let rToken = Sm2Token.shared.createAccessToken(privateKeyStr: UserDefault.getPrivateKey()!, publikeyStr: UserDefault.getPublickey()!)
                            /// 查找User表的头像cid   QmTpgJnPzkq1ist8CCT3cUFijd6STL2JjnwHzCMYNfR6sW
                            IPAProvider.request(NetworkAPI.queryOneData(token: rToken, tableName: DatabaseTableName.user.rawValue, appcode: APPCODE, fieldDic: ["dbchain_key":model.created_by])) { (cidResult) in
                                guard case .success(let cidResponse) = cidResult else { return }
                                let userJson = String(data: cidResponse.data, encoding: .utf8)
//                                print("查询评论的 头像!!!!")
                                if let userModel = BaseUserModel.deserialize(from: userJson) {
                                    if userModel.result?.count ?? 0 > 0 {
                                        /// 下载头像
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

//                                        if !usermodel!.photo.isBlank {
//                                            /// 判断本地是否有数据
//                                            let dicPath = documentTools() + "/\(usermodel!.photo)"
//                                            if FileTools.sharedInstance.isFileExisted(fileName: usermodel!.photo, path: dicPath) == true {
//                                                /// 本地有缓存数据.
//                                                /// 该文件已存在
//                                                let fileDic = FileTools.sharedInstance.filePathsWithDirPath(path: dicPath)
//                                                let imageData = try! Data(contentsOf: URL.init(fileURLWithPath: fileDic[0]))
//                                                model.imageData = imageData
//
//                                                if model.discuss_id.isBlank {
//                                                    mySelf.discussModelArr.append(model)
//                                                } else {
//                                                    model.replyNickName = usermodel!.name
//                                                    tempReplyArr.append(model)
//                                                }
//
//                                                if idx == baseDiscussModel.result!.count - 1 {
//                                                    signal.signal()
//                                                    group.leave()
//                                                }
//                                            } else {
//                                                let imageURL = DownloadFileURL + usermodel!.photo
//                                                DBRequest.GET(url: imageURL, params: nil) {[weak self] (imageJsonData) in
//                                                    guard let mySelf = self else {return}
//                                                    model.imageData = imageJsonData
//                                                    if model.discuss_id.isBlank {
//                                                        mySelf.discussModelArr.append(model)
//                                                    } else {
//                                                        model.replyNickName = usermodel!.name
//                                                        tempReplyArr.append(model)
//                                                    }
//                                                    if idx == baseDiscussModel.result!.count - 1 {
//                                                        signal.signal()
//                                                        group.leave()
//                                                    }
//                                                } failure: { (code, message) in
//                                                    print("头像下载失败")
//                                                    if idx == baseDiscussModel.result!.count - 1 {
//                                                        signal.signal()
//                                                        group.leave()
//                                                    }
//                                                }
//                                            }
//
//                                        } else {
//                                            if model.discuss_id.isBlank {
//                                                mySelf.discussModelArr.append(model)
//                                            } else {
//                                                model.replyNickName = usermodel!.name
//                                                tempReplyArr.append(model)
//                                            }
//                                            if idx == baseDiscussModel.result!.count - 1 {
//                                                signal.signal()
//                                                group.leave()
//                                            }
//                                        }

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
                } else {
                    signal.signal()
                    group.leave()
                    SwiftMBHUD.dismiss()
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
