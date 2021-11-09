//
//  Sm2InsertNetwork.swift
//  DBChainBlog
//
//  Created by iOS on 2021/10/26.
//

import Foundation
import DBChainKit
import Alamofire
import DBChainSm2

class Sm2InsertNetwork: NSObject {
    public var appcode :String
    public var publikeyBase64Str :String
    public var address :String
    public var tableName :String
    public var chainid :String
    public var privateKey :String
    public var baseUrl :String
    public var insertDataUrl: String
    public var publicKey :String
    var msgArr = [Dictionary<String, Any>]()
    // 准备签名数据
    let fee : [String:Any] = ["amount":[],"gas":"99999999"]

    required public init(baseUrl: String? = BASEURL,
                appcode: String? = APPCODE,
                address: String? = UserDefault.getAddress() ?? "",
                chainid: String? = Chainid,
                tableName: String,
                privateKey: String? = UserDefault.getPrivateKey()!,
                publicKey: String? = UserDefault.getPublickey()!,
                insertDataUrl: String) {

        self.appcode = appcode!
        self.address = address!
        self.tableName = tableName
        self.chainid = chainid!
        self.privateKey = privateKey!
        self.baseUrl = baseUrl!
        self.publicKey = publicKey!
        self.insertDataUrl = insertDataUrl
        /// 公钥 的 Base64
        publikeyBase64Str = publicKey!.hexaData.base64EncodedString()
    }


    /// 插入数据
    public func sm2_insertRowSortedSignDic(model:DBUserModel,fields : [String:Any],insertStatusBlock:@escaping(_ status:String) -> Void){

        let fieldsStr = fields.dicValueString(fields)
        let fieldsData = Data(fieldsStr!.utf8)
        let fieldBase = fieldsData.base64EncodedString()

         let valueDic:[String:Any] = ["app_code":appcode,
                                      "owner":address,
                                      "fields":fieldBase,
                                      "table_name":tableName]

         let msgDic:[String:Any] = ["type":"dbchain/InsertRow",
                                    "value":valueDic]
         msgArr.append(msgDic)

         let signDiv : [String:Any] = ["account_number":model.result.value.account_number,
                                       "chain_id":chainid,
                                       "fee":fee,
                                       "memo":"",
                                       "msgs":msgArr,
                                       "sequence":model.result.value.sequence]

        let str = signDiv.dicValueString(signDiv)
        var replacStr = str!.replacingOccurrences(of: "dbchain\\/InsertRow", with: "dbchain/InsertRow")
        replacStr = replacStr.replacingOccurrences(of: "\\/", with: "/")
        /// sm2 签名
        let plainHex = DBChainGMUtils.string(toHex: replacStr)
        let userHex = DBChainGMUtils.string(toHex: sm2UserID)
        let signStr = DBChainGMSm2Utils.signHex(plainHex!, privateKey: privateKey, userHex: userHex)

        print("私钥:\(privateKey)")
        print("公钥:\(publicKey)")
        print("原文:\(replacStr)")
        print("哈希原文:\(plainHex!)")
        print("签名:\(signStr!)")

        let signBase = signStr!.hexaData.base64EncodedString()
        print("签名 Base64: \(signBase)")

        let ver = DBChainGMSm2Utils.verifyHex(plainHex!, signRS: signStr!, publicKey: publicKey, userHex: userHex)
        print("验证签名结果: \(ver)")

        sm2_insertRowData(insertUrlStr: insertDataUrl, publikeyBase: publikeyBase64Str, signature: signBase) { (status) in
            insertStatusBlock(status)
        }
     }

    /// 最终提交数据
    /// - Parameters:
    ///   - urlStr: 插入数据的url地址.
    ///   - publikeyBase: 公钥的 base64 字符串
    ///   - signature: 签名数据
    ///   - insertDataStatusBlock: 返回结果. 类型为 int ,
    ///   返回结果的参数说明 :
    ///   返回 0  表示查询结果的倒计时结束, 数据插入不成功.
    ///   返回 1  表示数据已成功插入数据库
    ///   返回 2  表示该条数据插入的结果还处于等待状态.
    func sm2_insertRowData(insertUrlStr:String,
                       publikeyBase:String,
                        signature: String,
                        insertDataStatusBlock:@escaping(_ Status:String) -> Void) {

//        let sign = signature.base64EncodedString()

        let sortedDic = sortedDictionary(publickBaseStr: publikeyBase, signature: signature)

        let isTimerExistence = Sm2GCDTimer.shared.isExistTimer(WithTimerName: "VerificationHash")

        print("交易数据: \(sortedDic)")

        DBRequest.POST(url: insertUrlStr, params:( sortedDic )) { [self] (json) in
//            print(String(data: json, encoding: .utf8))
             let decoder = JSONDecoder()
             let insertModel = try? decoder.decode(DBInsertModel.self, from: json)
             guard let model = insertModel else {
                insertDataStatusBlock("0")
                 return
             }

            if !(model.txhash?.isBlank ?? true) {
                /// 开启定时器 循环查询结果
                if isTimerExistence == true{
                    Sm2GCDTimer.shared.cancleTimer(WithTimerName: "DBVerificationHash")
                }

                /// 查询请求最长等待时长
                var waitTime = 15
                
                // secp256k1
//                let token = DBToken().createAccessToken(privateKey: privateKeyDataUint, PublikeyData:self.publicKey.hexaData)

                /// sm2 token
                let token = Sm2Token().createAccessToken(privateKey: privateKey, PublikeyData: publicKey.hexaData)
                Sm2GCDTimer.shared.scheduledDispatchTimer(WithTimerName: "DBVerificationHash", timeInterval: 1, queue: .main, repeats: true) {
                    waitTime -= 1
                    if waitTime > 0 {
                        let requestUrl = baseUrl + "dbchain/tx-simple-result/" + "\(token)/" + "\(model.txhash!)"
                        verificationHash(url: requestUrl) { (status) in
                            NSLog("verificationHash:\(status),时间和次数:\(waitTime)")
                            if status != "2"{
                                //  成功或失败都直接返回 停止计时器
                                insertDataStatusBlock(status)
                                Sm2GCDTimer.shared.cancleTimer(WithTimerName: "DBVerificationHash")
                            }
                        }
                    } else {
                        /// 最长循环等待时间已过. 取消定时器
                        insertDataStatusBlock("0")
                        Sm2GCDTimer.shared.cancleTimer(WithTimerName: "DBVerificationHash")
                    }
                }
            } else {
                insertDataStatusBlock("0")
            }

         } failure: { (code, message) in

            if isTimerExistence == true{
                Sm2GCDTimer.shared.cancleTimer(WithTimerName: "DBVerificationHash")
            }
            insertDataStatusBlock("0")
        }
     }

    func sortedDictionary(publickBaseStr: String,signature:String) -> [String:Any] {
        let signDivSorted = ["key":["type":"tendermint/PubKeySm2",
                                    "value":publickBaseStr]]

        let typeSignDiv = sortedDictionarybyLowercaseString(dic: signDivSorted)

        let signDic = ["key":["pub_key":typeSignDiv[0],
                              "signature":signature]]

        let signDiv = sortedDictionarybyLowercaseString(dic: signDic)

        let tx = ["key":["memo":"",
                         "fee":fee,
                         "msg":msgArr,
                         "signatures":[signDiv[0]]]]

        let sortTX = sortedDictionarybyLowercaseString(dic: tx)

        let dataSort = sortedDictionarybyLowercaseString(dic: ["key": ["mode":"async","tx":sortTX[0]]])

        return dataSort[0]
    }

    /// 字典排序
    public func sortedDictionarybyLowercaseString(dic:Dictionary<String, Any>) -> [[String:Any]] {
        let allkeyArray  = dic.keys
        let afterSortKeyArray = allkeyArray.sorted(by: {$0 < $1})
        var valueArray = [[String:Any]]()
        afterSortKeyArray.forEach { (sortString) in
            let valuestring = dic[sortString]
            valueArray.append(valuestring as! [String:Any])
        }
        return valueArray
    }


    /// 检查数据是否已经插入成功
    /// - Parameters:
    //       let token = Token().createAccessToken()
    //       let requestUrl = BASEURL + "dbchain/tx-simple-result/" + "\(token)/" + "/\(hash)"
    ///   - url: 地址
    ///   - hash: 插入数据时返回的hash值
    /// - Returns: 不为空则是成功
    public func verificationHash(url:String,verifiSuccessBlock:@escaping(_ status: String) -> Void){
        DBRequest.GET(url: url, params: nil) { [weak self] (data) in
            guard let mySelf = self else {return}
            let json = mySelf.dataToJSON(data: data as NSData)
            print("验证结果: \(json)")
            if json.keys.count > 0 {
                /// 状态:  0: 错误 已经失败  1:  成功  2: 等待
                if json["error"] != nil {
                    verifiSuccessBlock("0")
                } else {
                    let result = json["result"] as? [String:Any]
                    let status = result?["state"]
                    if status as! String == "pending" {
                        verifiSuccessBlock("2")
                    } else if status as! String == "success" {
                        verifiSuccessBlock("1")
                    } else {
                        verifiSuccessBlock("0")
                    }
                }
            } else {
                verifiSuccessBlock("0")
            }

        } failure: { (code, message) in
            verifiSuccessBlock("0")
        }
    }

    public func dataToJSON(data:NSData) ->[String : Any] {
        var result = [String : Any]()

        if let dic = try? JSONSerialization.jsonObject(with: data as Data,
                                                       options: .mutableContainers) as? [String : Any] {
            result = dic
        }

        return result
    }

}
