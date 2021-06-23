//
//  BlogDetailView.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit

class BlogDetailView: UIView {

    var titleStr = "" {
        didSet {
            titleLabel.text = titleStr
            viewHeight += Int(self.heightForView(text: titleStr, font: UIFont.boldSystemFont(ofSize: 25), width: SCREEN_WIDTH - 32))
        }
    }

    var detailTitleStr = "" {
        didSet {
            let paragraphStyle = NSMutableParagraphStyle.init()
            paragraphStyle.lineSpacing = 8.0
            paragraphStyle.alignment = .justified
            let attributes = [NSAttributedString.Key.font:UIFont.ThemeFont.HeadRegular,
                              NSAttributedString.Key.paragraphStyle: paragraphStyle]
            textLabel.attributedText = NSAttributedString(string: detailTitleStr, attributes: attributes)
            viewHeight += Int(self.height(text: detailTitleStr))
        }
    }

    var viewHeight = 50 {
        didSet {
            headerView.frame = CGRect(x: 0, y: 0, width: Int(SCREEN_WIDTH), height: viewHeight + 140)
        }
    }

    lazy var tipLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont().themeHNBoldFont(size: 26)
        label.text = "SUPPORTS"
        return label
    }()

    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont().themeHNMediumFont(size: 25)
        label.numberOfLines = 0
        return label
    }()

    lazy var textLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.ThemeFont.HeadRegular
        label.numberOfLines = 0
        return label
    }()

    lazy var commentLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "热门评论"
        label.textAlignment = .center
        label.font = UIFont().themeHNBoldFont(size: 22)
        return label
    }()

    lazy var topComLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Top Comments"
        label.textAlignment = .center
        label.font = UIFont().themeHNBoldFont(size: 13)
        return label
    }()

    lazy var headerView : UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: Int(SCREEN_WIDTH), height: viewHeight))
        tipLabel.frame = CGRect(x: 16, y: 10, width: SCREEN_WIDTH - 32, height: 26)
        view.addSubViews([tipLabel,titleLabel,textLabel,commentLabel,topComLabel])
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(tipLabel.snp.bottom).offset(10)
        }

        textLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.left.right.equalTo(titleLabel)
        }

        commentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textLabel.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }

        topComLabel.snp.makeConstraints { (make) in
            make.top.equalTo(commentLabel.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }

        return view
    }()

    lazy var tableView : UITableView = {
        let view = UITableView.init(frame: self.frame, style: .grouped)
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + kNavAndTabHeight + 20, right: 0)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.separatorStyle = .none
        view.register(UINib.init(nibName: "BlogDetailTableViewCell", bundle: nil), forCellReuseIdentifier: BlogDetailTableViewCell.identifier)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.estimatedRowHeight = 84
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = headerView
        self.addSubview(tableView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// UILbale 文本高度
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{

           let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
           label.numberOfLines = 0
           label.lineBreakMode = NSLineBreakMode.byWordWrapping
           label.font = font
           label.text = text
           label.sizeToFit()

           return label.frame.height
       }

    /// 计算富文本高度
    func height(text: String) -> CGFloat {        // 注意这里的宽度计算，要根据自己的约束来计算
            let maxSize = CGSize(width: (SCREEN_WIDTH - 32), height: CGFloat(MAXFLOAT))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .justified
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = 8.0
            let labelSize = NSString(string: text).boundingRect(with: maxSize,
                                                                options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                                attributes:[.font : UIFont.ThemeFont.HeadRegular, .paragraphStyle: paragraphStyle],
                                                                context: nil).size
            return labelSize.height
    }

}

extension BlogDetailView : UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 3
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell :BlogDetailTableViewCell? = tableView.dequeueReusableCell(withIdentifier: BlogDetailTableViewCell.identifier, for: indexPath) as? BlogDetailTableViewCell

        if cell == nil {
            cell = BlogDetailTableViewCell.init(style: .default, reuseIdentifier: BlogDetailTableViewCell.identifier)
        }
        cell?.selectionStyle = .none
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0.01))
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 12))
    }
    
}
