//
//  LoginView.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import UIKit

// 退出,回到创建助记词界面
typealias LoginViewSignOutButtonBlock = () -> ()
// 立即进入
typealias LoginViewGoInButtonBlock = () -> ()

class LoginView: UIView {

    var signOutBlock :LoginViewSignOutButtonBlock?
    var goinBlock :LoginViewGoInButtonBlock?

    lazy var topImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.image = UIImage(named: "creat_top_image")
        return imgV
    }()

    lazy var centerBackView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.extSetCornerRadius(15)
        return view
    }()

    lazy var iconImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.image = UIImage(named: "home_icon_image")
        imgV.extSetCornerRadius(54)
        return imgV
    }()

    lazy var gooutBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "home_goout_btn_ img"), for: .normal)
        btn.addTarget(self, action: #selector(signOutButtonClick), for: .touchUpInside)
        return btn
    }()

    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont().themeHNBoldFont(size: 25)
        label.text = UserDefault.getUserNikeName() ?? "MASIKE"
        label.textAlignment = .center
        return label
    }()

    lazy var goInBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("立即进入", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont().themeHNFont(size: 24)
        btn.extSetCornerRadius(20)
        btn.backgroundColor = .colorWithHexString("2E44FF")
        btn.addTarget(self, action: #selector(goinButtonClick), for: .touchUpInside)
        return btn
    }()

    lazy var mnemonicBackView : UIView = {
        let view = UIView()
        view.backgroundColor = .colorWithHexString("EFEFEF")
        view.extSetCornerRadius(12)
        return view
    }()

    lazy var tipLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.ThemeFont.H2Medium
        label.text = "当前助记词"
        label.textAlignment = .center
        return label
    }()

    lazy var currentMnemonicLabel : UILabel = {
        let label = UILabel()
        label.textColor = .colorWithHexString("9E9E9E")
        label.numberOfLines = 0
        label.font = UIFont.ThemeFont.H3Regular
        label.text = UserDefault.getCurrentMnemonic()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        topImgV.frame = CGRect(x: SCREEN_WIDTH * 0.5 - 112, y: 0, width: 224, height: 48)
        centerBackView.frame = CGRect(x: 38, y: topImgV.frame.maxY + 35, width: SCREEN_WIDTH - 76, height: 315)
        self.addSubViews([topImgV,centerBackView])
        iconImgV.frame = CGRect(x: centerBackView.frame.width * 0.5 - 54, y: 40, width: 108, height: 108)
        gooutBtn.frame = CGRect(x: centerBackView.frame.width - 44, y: 22, width: 18, height: 18)
        nameLabel.frame = CGRect(x: 10, y: iconImgV.frame.maxY + 38, width: centerBackView.frame.width - 20, height: 26)
        goInBtn.frame = CGRect(x: centerBackView.frame.width * 0.5 - 100, y: nameLabel.frame.maxY + 20, width: 200, height: 64)
        centerBackView.addSubViews([iconImgV,gooutBtn,nameLabel,goInBtn])
        mnemonicBackView.frame = CGRect(x: 30, y: centerBackView.frame.maxY + 24, width: SCREEN_WIDTH - 60, height: 168)
        self.addSubview(mnemonicBackView)

        tipLabel.frame = CGRect(x: 20, y: 22, width: mnemonicBackView.frame.width - 40, height: 20)
        mnemonicBackView.addSubViews([tipLabel,currentMnemonicLabel])
        currentMnemonicLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tipLabel.snp.bottom).offset(16)
            make.right.equalTo(mnemonicBackView).offset(-20)
            make.left.equalTo(mnemonicBackView).offset(20)
        }
    }

    @objc func goinButtonClick() {
        if self.goinBlock != nil {
            self.goinBlock!()
        }
    }

    @objc func signOutButtonClick() {
        if self.signOutBlock != nil {
            self.signOutBlock!()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
