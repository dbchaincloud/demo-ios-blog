//
//  CreateMnemonicView.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import Foundation
import UIKit

typealias CreateGoInButtonClickBlock = () -> ()
typealias CreateMnemonicButtonClickBlock = () -> ()

class CreateMnemonicView: UIView {
    var goinButtonBlock :CreateGoInButtonClickBlock?
    var createMnemonicBlock :CreateMnemonicButtonClickBlock?

    var mnemonicStr = ""{
        didSet{
            mnemonicLabel.text = mnemonicStr
        }
    }

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

    lazy var topBackView : UIView = {
        let view = UIView()
        view.extSetCornerRadius(11)
        view.backgroundColor = .colorWithHexString("F8F8F8")
        return view
    }()

    lazy var tipLabel : UILabel = {
        let label = UILabel()
        label.text = "助记词"
        label.textColor = .black
        label.font = UIFont.ThemeFont.H2Medium
        label.textAlignment = .center
        return label
    }()

    lazy var mnemonicLabel : UILabel = {
        let label = UILabel()
        label.textColor = .colorWithHexString("3B3B3B")
        label.font = UIFont.ThemeFont.H3Regular
        label.numberOfLines = 0
        return label
    }()

    lazy var nameTextField : UITextField = {
        let tf = UITextField()
        let placeholserAttributes = [NSAttributedString.Key.foregroundColor : UIColor.colorWithHexString("000000"),NSAttributedString.Key.font : UIFont().themeHNBoldFont(size: 25)]
        tf.attributedPlaceholder = NSAttributedString.init(string: "取个昵称", attributes: placeholserAttributes)
        tf.backgroundColor = .colorWithHexString("F8F8F8")
        tf.textAlignment = .center
        tf.extSetCornerRadius(20)
        return tf
    }()

    lazy var goInBtn : UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .colorWithHexString("2E44FF")
        btn.extSetCornerRadius(20)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("立即进入", for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.H2Regular
        return btn
    }()

    lazy var createMnemonicBtn : UIButton = {
        let btn = UIButton()
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.colorWithHexString("2E44FF").cgColor
        btn.extSetCornerRadius(20)
        btn.setTitleColor(.colorWithHexString("2E44FF"), for: .normal)
        btn.setTitle("生成助记词", for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.H2Regular
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        topImgV.frame = CGRect(x: SCREEN_WIDTH * 0.5 - 112, y: 25, width: 224, height: 48)
        centerBackView.frame = CGRect(x: 10, y: topImgV.frame.maxY + 32, width: SCREEN_WIDTH - 20, height: 520)
        self.addSubViews([topImgV,centerBackView])
        topBackView.frame = CGRect(x: 20, y: 35, width: centerBackView.frame.width - 40, height: 200)
        centerBackView.addSubview(topBackView)
        tipLabel.frame = CGRect(x: 20, y: 28, width: topBackView.frame.width - 40, height: 22)
        mnemonicLabel.frame = CGRect(x: 20, y: tipLabel.frame.maxY + 14, width: topBackView.frame.width - 40, height: 100)
        topBackView.addSubViews([tipLabel,mnemonicLabel])

        nameTextField.frame = CGRect(x: 20, y: topBackView.frame.maxY + 12, width: centerBackView.frame.width - 40, height: 62)
        goInBtn.frame = CGRect(x: 26, y: nameTextField.frame.maxY + 26, width: centerBackView.frame.width - 52, height: 64)
        goInBtn.addTarget(self, action: #selector(clickGoInBtn), for: .touchUpInside)
        createMnemonicBtn.frame = CGRect(x: 26, y: goInBtn.frame.maxY + 22, width: centerBackView.frame.width - 52, height: 64)
        createMnemonicBtn.addTarget(self, action: #selector(clickCreateMnemonicBtn), for: .touchUpInside)
        centerBackView.addSubViews([nameTextField,goInBtn,createMnemonicBtn])

    }

    @objc func clickGoInBtn(){
        if self.nameTextField.text?.count == 0 {
            SwiftMBHUD.showError("请输入昵称")
        } else {
            if self.goinButtonBlock != nil {
                self.goinButtonBlock!()
            }
        }
    }

    @objc func clickCreateMnemonicBtn(){
        if self.createMnemonicBlock != nil {
            self.createMnemonicBlock!()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
