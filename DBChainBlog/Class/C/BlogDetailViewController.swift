//
//  BlogDetailViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit

class BlogDetailViewController: BaseViewController {

    lazy var contentView : BlogDetailView = {
        let view = BlogDetailView.init(frame: self.view.frame)
        return view
    }()

    var logModel = blogModel()

    override func setupUI() {
        super.setupUI()
        self.title = "帖子详情"

        self.view.addSubview(contentView)
        contentView.titleStr = logModel.title
        contentView.detailTitleStr = logModel.body

    }

}
