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
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentTitleLabel: UILabel!
    @IBOutlet weak var replyBtn: UIButton!

    var model = discussModel(){
        didSet{
            if model.imageData != nil {
                iconImgV.image = UIImage(data: model.imageData!)
            }else{
                iconImgV.image = UIImage(named: "home_icon_image")
            }

            if !model.nickName.isBlank {
                nameLabel.text = model.nickName
            } else {
                nameLabel.text = "未知用户"
            }

            contentTitleLabel.text = model.text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        self.iconImgV.contentMode = .scaleAspectFill
        self.backView.extSetCornerRadius(15)
        self.iconImgV.extSetCornerRadius(24)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
