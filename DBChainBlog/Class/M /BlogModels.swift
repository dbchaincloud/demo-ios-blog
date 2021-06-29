//
//  BlogModels.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/24.
//

import Foundation
import HandyJSON

class BaseBlogsModel: HandyJSON {
    var height : String?
    var result : [blogModel]?
    required init(){}
}

class blogModel: HandyJSON {
    var id: String = ""
    var created_by: String = ""
    var created_at: String = ""
    var title:String = ""
    var body: String = ""
    var name: String = ""
    var imgdata: Data?
    var readNumber: Int?
    required init(){}
}

class BaseUserModel: HandyJSON {
    var height : String?
    var result : [userModel]?
    required init(){}
}

class userModel: HandyJSON {
    var id: String = ""
    var created_by: String = ""
    var created_at: String = ""
    /// 昵称
    var name:String = ""
    /// 年龄
    var age: String = ""
    /// 库链地址
    var dbchain_key: String = ""
    /// 性别
    var sex: String = ""
    /// 账号是否可用
    var status: String = ""
    /// 头像
    var photo: String = ""
    /// 座右铭
    var motto: String = ""
    required init(){}
}


class BaseDiscussModel: HandyJSON {
    var height : String?
    var result : [discussModel]?
    required init(){}
}

class discussModel: HandyJSON,Equatable {
    static func == (lhs: discussModel, rhs: discussModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.created_at == rhs.created_at &&
            lhs.created_by == rhs.created_by &&
            lhs.blog_id == rhs.blog_id &&
            lhs.discuss_id == rhs.discuss_id &&
            lhs.text == rhs.text &&
            lhs.imageData == rhs.imageData &&
            lhs.nickName == rhs.nickName &&
            lhs.replyModelArr == rhs.replyModelArr &&
            lhs.replyNickName == rhs.replyNickName
    }

    var id: String = ""
    var created_by: String = ""
    var created_at: String = ""
    /// 文章id
    var blog_id:String = ""
    /// 评论id
    var discuss_id: String = ""
    /// 评论内容
    var text: String = ""

    /// 自定义类型.  头像
    var imageData:Data?
    var nickName: String = ""

    var replyModelArr :[replyDiscussModel] = []
    /// 回复人的昵称
    var replyNickName: String = ""
    required init(){}
}

//class BaseReplyDiscussModel: HandyJSON {
//    var height : String?
//    var result : [replyDiscussModel]?
//    required init(){}
//}

class replyDiscussModel: HandyJSON,Equatable {

    static func == (lhs: replyDiscussModel, rhs: replyDiscussModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.created_at == rhs.created_at &&
            lhs.created_by == rhs.created_by &&
            lhs.blog_id == rhs.blog_id &&
            lhs.discuss_id == rhs.discuss_id &&
            lhs.text == rhs.text &&
            lhs.imageData == rhs.imageData &&
            lhs.nickName == rhs.nickName &&
            lhs.replyID == rhs.replyID &&
            lhs.replyNickName == rhs.replyNickName
    }

    var id: String = ""

    var created_by: String = ""
    var created_at: String = ""
    /// 文章id
    var blog_id:String = ""
    /// 评论id
    var discuss_id: String = ""
    /// 评论内容
    var text: String = ""
    /// 自定义类型.  头像
    var imageData:Data?
    var nickName: String = ""

    /// 回复id
    var replyID :String = ""
    /// 回复人的昵称
    var replyNickName: String = ""
    required init(){}
}
