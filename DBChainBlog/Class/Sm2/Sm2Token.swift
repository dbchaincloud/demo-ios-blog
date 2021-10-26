//
//  Sm2Token.swift
//  DBChainBlog
//
//  Created by iOS on 2021/10/26.
//

import Foundation
import DBChainKit
import DBChainSm2

let sm2UserID = "1234567812345678"
public struct Sm2Token {

    public init(){}

    /// 获取当前 毫秒级 时间戳 - 13位
    public  var milliStamp : String {
          let timeInterval: TimeInterval = Date().timeIntervalSince1970
          let millisecond = CLongLong(round(timeInterval*1000))
          return "\(millisecond)"
      }


    /// 获取Token
    /// - Parameters:
    ///   - privateKey: 秘钥  Uint8 数组形式
    ///   - PublikeyData: 公钥  Data 形式
    /// - Returns: 成功则 返回Token. 错误返回空
    public func createAccessToken(privateKey:String,PublikeyData:Data) -> String {
        let millisecond = self.milliStamp
        let secondUint = [UInt8](millisecond.utf8)
//        do{
//            let signMilliSecond = try signSawtoothSigning(data: secondUint, privateKey: privateKey)

            // sm2 签名
            let plainHex = DBChainGMUtils.string(toHex: self.milliStamp)
            let userHex = DBChainGMUtils.string(toHex: sm2UserID)
            let signMilliSecond = DBChainGMSm2Utils.signHex(plainHex!, privateKey: privateKey, userHex: userHex)

            let timeBase58 = Base58.encode(signMilliSecond!.hexaData)
            print("Token: --- SignHexData: \(signMilliSecond!.hexaData) \nStringData:\(Data(hex: signMilliSecond!))")

            let publicKeyBase58 = Base58.encode(PublikeyData)

            return "\(publicKeyBase58):" + "\(millisecond):" + "\(timeBase58)"

//        } catch {
//            return ""
//        }
    }
}
