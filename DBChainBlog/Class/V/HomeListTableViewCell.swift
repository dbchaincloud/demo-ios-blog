//
//  HomeListTableViewCell.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import UIKit
import Kingfisher

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
            if model.readNumber != nil {
                redNumberLabel.text = "\(model.readNumber!)"
            }
            if model.imgUrl != nil {
                iconImageV.kf.setImage(with: URL(string: dbchain.baseurl! + "ipfs/" + model.imgUrl!),placeholder: UIImage(named: "home_icon_image"))
            } else {
                iconImageV.image = UIImage(named: "home_icon_image")
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
