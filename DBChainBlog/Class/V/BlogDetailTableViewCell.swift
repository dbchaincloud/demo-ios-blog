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

//            if model.replyModelArr.count > 0 {
//                for rmodel in model.replyModelArr {
//                    if rmodel.imageData != nil {
//                        iconImgV.image = UIImage(data: model.imageData!)
//                    } else {
//                        iconImgV.image = UIImage(named: "home_icon_image")
//                    }
//                    if !rmodel.nickName.isBlank {
//                        nameLabel.text = model.nickName
//                    } else {
//                        nameLabel.text = "未知用户"
//                    }
//                    contentTitleLabel.text = rmodel.text
//                }
//
//            } else {
//
//
//            }

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
            print("cell id: \(model.id) -- \(model.discuss_id) +++++ :\(model.replyModelArr)")
        }
    }


    var replyModel = replyDiscussModel() {
        didSet{
            if replyModel.imageData != nil {
                iconImgV.image = UIImage(data: replyModel.imageData!)
            }else{
                iconImgV.image = UIImage(named: "home_icon_image")
            }

            if !replyModel.nickName.isBlank {
                nameLabel.text = replyModel.nickName
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
