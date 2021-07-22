//
//  HomeListView.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import UIKit

typealias HomeListTableViewDidSelectCellIndexBlock = (_ index:IndexPath) -> ()
class HomeListView: UIView {

    var HomeListDidSelectIndexBlock :HomeListTableViewDidSelectCellIndexBlock?

    var modelArr:[blogModel] = [] {
        didSet{
            self.tableView.reloadData()
        }
    }

    lazy var tableView : UITableView = {
        let view = UITableView.init(frame: CGRect(x: 0, y: 10, width: SCREEN_WIDTH, height: self.frame.height - 10), style: .grouped)
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + kNavAndTabHeight + 20, right: 0)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.separatorStyle = .none
        view.register(UINib.init(nibName: "HomeListTableViewCell", bundle: nil), forCellReuseIdentifier: HomeListTableViewCell.identifier)
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

extension HomeListView:UITableViewDelegate,UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.modelArr.count
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
        cell?.model = self.modelArr[indexPath.section]
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.HomeListDidSelectIndexBlock != nil {
            self.HomeListDidSelectIndexBlock!(indexPath)
        }
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
