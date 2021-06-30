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
            print("cell id: \(model.id) -- \(model.discuss_id) +++++ :\(model.replyModelArr)")
        }
    }


    var replyModel = replyDiscussModel() {
        didSet{
            if replyModel.imageData != nil {

                let img = UIImage(data: replyModel.imageData!)
                if img != nil {
                    iconImgV.image = img
                } else {
                    iconImgV.image = UIImage(named: "home_icon_image")
                }

            } else {
                iconImgV.image = UIImage(named: "home_icon_image")
            }

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
        self.backgroundColor = .white
        self.iconImgV.contentMode = .scaleAspectFill
        self.iconImgV.extSetCornerRadius(24)
        self.contentTitleLabel.numberOfLines = 0
    }

    //覆盖frame，自动添加边距
      override var frame: CGRect {
          get {
              return super.frame
          }
          set {
              var frame = newValue
              frame.origin.x += 15
              frame.origin.y += 0
              frame.size.width -= 2 * 15
              frame.size.height -= 0
              super.frame = frame
          }
      }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
