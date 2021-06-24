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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var iconImageV: UIImageView!
    @IBOutlet weak var namelabel: UILabel!
    @IBOutlet weak var redNumberLabel: UILabel!

    var model = blogModel() {
        didSet{
            titleLabel.text = model.title
            bodyLabel.text = model.body
            namelabel.text = model.name
            redNumberLabel.text = "\(model.readNumber!)"
            if model.imgdata != nil {
                iconImageV.image = UIImage(data: model.imgdata!)
            }
        }
    }

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
