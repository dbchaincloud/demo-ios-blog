//
//  HomeListViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import UIKit

class HomeListViewController: BaseViewController {

    lazy var contentView : HomeListView = {
        let view = HomeListView.init(frame: self.view.frame)
        return view
    }()

    override func setupUI() {
        super.setupUI()

        view.addSubview(contentView)
        contentView.HomeListDidSelectIndexBlock = { (index: IndexPath) in
            let vc = BlogDetailViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}

extension HomeListViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
