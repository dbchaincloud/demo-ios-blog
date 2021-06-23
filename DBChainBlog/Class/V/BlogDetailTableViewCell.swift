//
//  BlogDetailTableViewCell.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit

class BlogDetailTableViewCell: UITableViewCell {

    static let identifier = "BlogDetailCellID"

    @IBOutlet weak var backView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        self.backView.extSetCornerRadius(15)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
