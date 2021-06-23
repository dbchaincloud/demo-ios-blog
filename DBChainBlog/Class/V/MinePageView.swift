//
//  MinePageView.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit

class MinePageView: UIView {

    lazy var iconImgV : UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "home_icon_image")
        return imgv
    }()

    lazy var nikeNameLabel : UILabel = {
        let label = UILabel()
        label.text = "MASIKE"
        label.textColor = .black
        label.font = UIFont().themeHNBoldFont(size: 25)
        return label
    }()

    lazy var signLabel : UILabel = {
        let label = UILabel()
        label.textColor = .colorWithHexString("444444")
        label.font = UIFont().themeHNFont(size: 16)
        label.text = "留下一句座右铭吧~"
        return label
    }()

    lazy var genderImgV : UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "homepage_gender_female")
        return imgv
    }()

    lazy var headerView : UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 254))
        iconImgV.frame = CGRect(x: SCREEN_WIDTH * 0.5 - 54, y: 40, width: 108, height: 108)
        view.addSubViews([iconImgV,nikeNameLabel,signLabel,genderImgV])
        nikeNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconImgV.snp.bottom).offset(15)
            make.centerX.equalTo(iconImgV).offset(-12)
        }

        signLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(iconImgV)
            make.top.equalTo(iconImgV.snp.bottom).offset(56)
        }

        genderImgV.snp.makeConstraints { (make) in
            make.centerY.equalTo(nikeNameLabel)
            make.left.equalTo(nikeNameLabel.snp.right).offset(16)
            make.width.height.equalTo(23)
        }

        return view
    }()

    lazy var tableView : UITableView = {
        let view = UITableView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: self.frame.height), style: .grouped)
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kNavAndTabHeight + 20, right: 0)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.separatorStyle = .none
        view.register(UINib.init(nibName: "HomeListTableViewCell", bundle: nil), forCellReuseIdentifier: HomeListTableViewCell.identifier)
        view.tableHeaderView = headerView
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(tableView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MinePageView : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell :HomeListTableViewCell? = tableView.dequeueReusableCell(withIdentifier: HomeListTableViewCell.identifier, for: indexPath) as? HomeListTableViewCell

        if cell == nil {
            cell = HomeListTableViewCell.init(style: .default, reuseIdentifier: HomeListTableViewCell.identifier)
        }
        cell?.selectionStyle = .none
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
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
