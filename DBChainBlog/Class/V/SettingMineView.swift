//
//  SettingMineView.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit

class SettingMineView: UIView {

    lazy var iconButton : UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(named: "home_icon_image"), for: .normal)
        btn.setBackgroundImage(UIImage(named: "home_icon_image"), for: .selected)
        btn.setImage(UIImage(named: "setting_mine_camera"), for: .normal)
        btn.setImage(UIImage(named: "setting_mine_camera"), for: .selected)
        return btn
    }()

    lazy var nameTextField : UITextField = {
        let tf = UITextField()
        tf.text = "MASIKE"
        tf.textColor = .black
        tf.font = UIFont().themeHNBoldFont(size: 25)
        return tf
    }()

    lazy var girlButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "homepage_gender_female"), for: .normal)
        btn.backgroundColor = .colorWithHexString("EFEFEF")
        btn.extSetCornerRadius(10)
        return btn
    }()

    lazy var bodyButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "setting_gender_boy"), for: .normal)
        btn.extSetCornerRadius(10)
        return btn
    }()

    lazy var ageTextfield : UITextField = {
        let tf = UITextField()
        tf.text = "22"
        tf.textColor = .black
        tf.font = UIFont().themeHNBoldFont(size: 28)
        return tf
    }()

    lazy var signTextfield : UITextField = {
        let tf = UITextField()
        tf.placeholder = "留下一句座右铭吧~"
        tf.textColor = .black
        tf.font = UIFont.ThemeFont.HeadRegular
        return tf
    }()

    lazy var saveBtn : UIButton = {
        let btn = UIButton()
        btn.extSetCornerRadius(20)
        btn.backgroundColor = .colorWithHexString("2E44FF")
        btn.setTitle("保存", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.H2Bold
        return btn
    }()

    let tipStrArr = ["昵称","性别","年龄","座右铭"]

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(iconButton)
        self.addSubview(saveBtn)

        iconButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.width.height.equalTo(108)
        }

        saveBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(64)
            make.bottom.equalToSuperview().offset(-kTabBarHeight-50)
        }

        var backViewHeight :Int = 66
        for index in 0..<tipStrArr.count {
            if index == tipStrArr.count - 1 {
                backViewHeight = 100
            }
            let backView = UIView.init(frame: CGRect(x: 37, y: CGFloat(150 + index * 66 + index * 14), width: SCREEN_WIDTH - 74, height: CGFloat(backViewHeight)))
            backView.backgroundColor = .white
            backView.extSetCornerRadius(15)
            let tipLabel = UILabel.init(frame: CGRect(x: 25, y: 22, width: 100, height: 22))
            tipLabel.textColor = .black
            tipLabel.font = UIFont.ThemeFont.H2Medium
            tipLabel.text = tipStrArr[index]
            backView.addSubview(tipLabel)

            switch index {
            case 0:
                nameTextField.frame = CGRect(x: 105, y: 20, width: SCREEN_WIDTH - 190, height: 26)
                backView.addSubview(nameTextField)
            case 1:
                girlButton.frame = CGRect(x: 105, y: 15, width: 36, height: 36)
                bodyButton.frame = CGRect(x: 160, y: 15, width: 36, height: 36)
                backView.addSubViews([girlButton,bodyButton])
            case 2:
                ageTextfield.frame = CGRect(x: 105, y: 19, width: 100, height: 28)
                backView.addSubview(ageTextfield)
            default:
                signTextfield.frame = CGRect(x: 25, y: 52, width: SCREEN_WIDTH - 124, height: 26)
                backView.addSubview(signTextfield)
            }
            self.addSubview(backView)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
