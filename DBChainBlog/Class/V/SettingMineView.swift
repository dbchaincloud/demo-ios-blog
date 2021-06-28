//
//  SettingMineView.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit

typealias SettingMineUserInfoBlock = (_ nameStr:String,_ sex:String,_ age: String,_ motto:String) -> ()
typealias SettingClickIconImageViewBlock = () -> ()

class SettingMineView: UIView {

    var settingSaveBlock : SettingMineUserInfoBlock?
    var settingIconImageViewBlock :SettingClickIconImageViewBlock?

    var umodel = userModel(){
        didSet{
            if !umodel.name.isBlank { nameTextField.text = umodel.name }
            if !umodel.motto.isBlank { signTextfield.text = umodel.motto }
            if !umodel.age.isBlank  {
                ageTextfield.text = umodel.age
            }
            if umodel.sex == "0" {
                bodyButton.backgroundColor = .clear
                girlButton.backgroundColor = .colorWithHexString("EFEFEF")
                selectSex = "0"
            } else {
                bodyButton.backgroundColor = .colorWithHexString("EFEFEF")
                girlButton.backgroundColor = .clear
                selectSex = "1"
            }
        }
    }

    var iconImage = UIImage() {
        didSet{
            iconButton.setBackgroundImage(iconImage, for: .normal)
            iconButton.setBackgroundImage(iconImage, for: .selected)
        }
    }

    lazy var iconButton : UIButton = {
        let btn = UIButton()
        let filePath = documentTools() + "/USERICONPATH"
        if FileTools.sharedInstance.isFileExisted(fileName: USERICONPATH, path: filePath) == true {
            let fileDic = FileTools.sharedInstance.filePathsWithDirPath(path: filePath)
            let imageData = try! Data(contentsOf: URL.init(fileURLWithPath: fileDic[0]))
            btn.setBackgroundImage(UIImage(data: imageData)!, for: .normal)
            btn.setBackgroundImage(UIImage(data: imageData)!, for: .selected)
        } else {
            btn.setBackgroundImage(UIImage(named: "home_icon_image"), for: .normal)
            btn.setBackgroundImage(UIImage(named: "home_icon_image"), for: .selected)
        }
        btn.setImage(UIImage(named: "setting_mine_camera"), for: .normal)
        btn.setImage(UIImage(named: "setting_mine_camera"), for: .selected)
        btn.addTarget(self, action: #selector(selectIconImageViewClick), for: .touchUpInside)
        return btn
    }()

    lazy var nameTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "设置昵称"
        tf.textColor = .black
        tf.font = UIFont().themeHNBoldFont(size: 25)
        return tf
    }()

    lazy var girlButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "homepage_gender_female"), for: .normal)
        btn.extSetCornerRadius(10)
        btn.addTarget(self, action: #selector(clickSexButtonWithGirl), for: .touchUpInside)
        return btn
    }()

    lazy var bodyButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "setting_gender_boy"), for: .normal)
        btn.extSetCornerRadius(10)
        btn.backgroundColor = .colorWithHexString("EFEFEF")
        btn.addTarget(self, action: #selector(clickSexButtonWithBody), for: .touchUpInside)
        return btn
    }()

    lazy var ageTextfield : UITextField = {
        let tf = UITextField()
        tf.placeholder = "设置年龄"
        tf.textColor = .black
        tf.keyboardType = .numberPad
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
        btn.addTarget(self, action: #selector(saveUserInfomationClick), for: .touchUpInside)
        return btn
    }()

    var selectSex = ""
    let tipStrArr = ["昵称","性别","年龄","座右铭"]

    override init(frame: CGRect) {
        super.init(frame: frame)

        iconButton.extSetCornerRadius(54)
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
                ageTextfield.frame = CGRect(x: 105, y: 19, width: SCREEN_WIDTH - 190, height: 28)
                backView.addSubview(ageTextfield)
            default:
                signTextfield.frame = CGRect(x: 25, y: 52, width: SCREEN_WIDTH - 124, height: 26)
                backView.addSubview(signTextfield)
            }
            self.addSubview(backView)
        }
    }

    @objc func clickSexButtonWithGirl (){
        bodyButton.backgroundColor = .clear
        girlButton.backgroundColor = .colorWithHexString("EFEFEF")
        selectSex = "0"
    }


    @objc func clickSexButtonWithBody (){
        bodyButton.backgroundColor = .colorWithHexString("EFEFEF")
        girlButton.backgroundColor = .clear
        selectSex = "1"
    }

    @objc func saveUserInfomationClick() {
        if self.settingSaveBlock != nil {
            self.settingSaveBlock!(self.nameTextField.text!, self.selectSex, self.ageTextfield.text!, self.signTextfield.text!)
        }
    }

    @objc func selectIconImageViewClick() {
        if self.settingIconImageViewBlock != nil {
            self.settingIconImageViewBlock!()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
