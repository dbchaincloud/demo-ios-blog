//
//  BlogDetailTableViewCell.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit

class BlogDetailTableViewCell: UITableViewCell {

    static let identifier = "BlogDetailCellID"
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentTitleLabel: UILabel!
    @IBOutlet weak var backView: UIView!

    var replyModel = replyDiscussModel() {
        didSet{
            self.iconImgV.kf.setImage(with: URL(string: dbchain.baseurl! + "ipfs/" + replyModel.imageIndex), placeholder: UIImage(named: "home_icon_image"))
            if !replyModel.nickName.isBlank {
                nameLabel.text = replyModel.nickName + " 回复 " + replyModel.replyNickName
            } else {
                nameLabel.text = "未知用户"
            }
            contentTitleLabel.text = replyModel.text
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        self.iconImgV.contentMode = .scaleAspectFill
        self.iconImgV.extSetCornerRadius(24)
        self.contentTitleLabel.numberOfLines = 0
    }

    //覆盖frame，自动添加边距
//      override var frame: CGRect {
//          get {
//              return super.frame
//          }
//          set {
//              var frame = newValue
//              frame.origin.x += 15
//              frame.origin.y += 0
//              frame.size.width -= 2 * 15
//              frame.size.height -= 0
//              super.frame = frame
//          }
//      }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
