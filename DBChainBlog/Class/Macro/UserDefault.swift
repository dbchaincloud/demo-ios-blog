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

    /// 保存地址
    static func saveAddress(_ address:String){
        UserDefaults.standard.setValue(address, forKey: "kAddressKey")
    }
    /// 取出地址
    static func getAddress() -> String?{
        return UserDefaults.standard.string(forKey: "kAddressKey")
    }

    /// 保存公钥
    static func savePublickey(_ publicKey:String){
        UserDefaults.standard.setValue(publicKey, forKey: "kPublickKey")
    }
    /// 取出公钥
    static func getPublickey() -> String?{
        return UserDefaults.standard.string(forKey: "kPublickKey")
    }

    /// 保存私钥
    static func savePrivateKey(_ privateKey:String){
        UserDefaults.standard.setValue(privateKey, forKey: "kPrivateKey")
    }
    /// 取出私钥
    static func getPrivateKey() -> String?{
        return UserDefaults.standard.string(forKey: "kPrivateKey")
    }

    /// 保存私钥 [Uint8]
    static func savePrivateKeyUintArr(_ uintArr:[Any]){
        UserDefaults.standard.setValue(uintArr, forKey: "kPrivateKeyUintArrKey")
    }
    
    /// 取出私钥 [Uint8]
    static func getPrivateKeyUintArr() -> [Any]? {
        return UserDefaults.standard.array(forKey: "kPrivateKeyUintArrKey")
    }


}
