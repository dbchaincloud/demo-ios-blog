//
//  HomeListTableViewCell.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import UIKit

class HomeListTableViewCell: UITableViewCell {
    static let identifier = "ListViewCell"

    @IBOutlet weak var backView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        backView.extSetCornerRadius(14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
