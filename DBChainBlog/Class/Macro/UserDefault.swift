//
//  UserDefault.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import UIKit

class UserDefault: NSObject {
    /// 保存助记词
    static func saveCurrentMnemonic(_ mnemonicStr:String){
        UserDefaults.standard.setValue(mnemonicStr, forKey: "kCurrentMnemonic")
    }
    /// 取出当前助记词
    static func getCurrentMnemonic() -> String?{
        return UserDefaults.standard.string(forKey: "kCurrentMnemonic")
    }
}
