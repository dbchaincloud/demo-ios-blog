//
//  CreateMnemonicController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
// creat_top_image

import Foundation
import UIKit
import Alamofire
import GMChainSm2
import HDWalletSDK
import DBChainSm2

class CreateMnemonicController: BaseViewController {

    lazy var contentView : CreateMnemonicView = {
        let view = CreateMnemonicView.init(frame: self.view.frame)
        return view
    }()

    var mnemonicStr :String! = "" {
        didSet {
            contentView.mnemonicStr = mnemonicStr
        }
    }

//    var token = ""

    override func setupUI() {
        super.setupUI()

        view.addSubview(contentView)

        mnemonicStr = Sm2Mnemonic().createMnemonicString()

        /// 生成助记词
        contentView.createMnemonicBlock = {
            self.mnemonicStr = Sm2Mnemonic().createMnemonicString()

//             API 查询例子
//            self.alamofireQueryOneData(privateKey: UserDefault.getPrivateKey()!, publicKey: UserDefault.getPublickey()!, appcode: APPCODE)

        }

        /// 进入首页
        contentView.goinButtonBlock = { [self] in
            SwiftMBHUD.showLoading()
            UserDefault.saveCurrentMnemonic(self.mnemonicStr)
            let lowMnemoicStr = self.mnemonicStr.lowercased()
            let seedBip39 = Mnemonic.createSeed(mnemonic: lowMnemoicStr)
//            let privateKey = PrivateKey(seed: seedBip39, coin: .bitcoin)
//            // 派生
//            let purpose = privateKey.derived(at: .hardened(44))
//            let coinType = purpose.derived(at: .hardened(118))
//            let account = coinType.derived(at: .hardened(0))
//            let change = account.derived(at: .notHardened(0))
//            let firstPrivateKey = change.derived(at: .notHardened(0))

            let privatekey = Sm2PrivateKey(seed: seedBip39, coin: .bitcoin)
            let privatekeyStr = privatekey.createSm2PrivateKey()
            // 生成 Sm2 公钥
            let publicKey = DBChainGMSm2Utils.adoptPrivatekeyGetPublicKey(privatekeyStr, isCompress: true)
            // 生成 dbchain 地址
            let sm2PublickeyData = publicKey.hexaData

            let address = Sm2ChainAddress.shared.sm2GetPubToDpAddress(sm2PublickeyData, .DBCHAIN_MAIN)

            print("私钥:\(privatekeyStr)")
            print("公钥:\(publicKey)")
            print("地址:\(address)")

            if address.count > 0, publicKey.count > 0 {
                let token = Sm2Token.shared.createAccessToken(privateKeyStr: privatekeyStr, publikeyStr: publicKey)
                IPAProvider.request(NetworkAPI.getIntegralUrl(token: token)) { [weak self] (result) in
                    guard let mySelf = self else {return}
                    guard case .success(let response) = result else { SwiftMBHUD.showError("获取积分失败");return }
                    let jsonStr = String(data: response.data, encoding: .utf8)
                    if jsonStr!.isjsonStyle() {
                        let dic : [String : Any] = (jsonStr?.toDictionary())!
                        guard !dic.keys.contains("error") else { SwiftMBHUD.showError("请求错误"); return }
                        if dic["result"] as! String == "success" {
                            print("获取积分成功!!!")
                            UserDefault.saveUserNikeName(contentView.nameTextField.text!)
                            UserDefault.saveAddress(address)
                            UserDefault.savePublickey(publicKey)
                            UserDefault.savePrivateKey(privatekeyStr)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            mySelf.insertUserInfo(address: address, publicKey: publicKey, privateKey: privatekeyStr)
                            }
                        } else { SwiftMBHUD.showError("获取积分失败") }
                    }
                }

//                Api 例子
//                self.alamofireRequest(token: token)

            } else {
                SwiftMBHUD.showText("助记词错误 无法生成公钥与私钥")
            }
        }
    }


    func insertUserInfo(address: String,publicKey: String, privateKey: String) {
        IPAProvider.request(NetworkAPI.getUserModelUrl(address: address)) {[weak self] (userResult) in
            guard let mySelf = self else {return}
            guard case .success(let userResponse) = userResult else { SwiftMBHUD.showError("获取用户信息失败");return }
            do {
                let model = try JSONDecoder().decode(ChainUserModel.self, from: userResponse.data)
                let fieldsDic = ["name":mySelf.contentView.nameTextField.text!,
                                 "age":"",
                                 "dbchain_key":address,
                                 "sex":"",
                                 "status":"",
                                 "photo":"",
                                 "motto":""] as [String : Any]
                IPAProvider.request(NetworkAPI.insertData(userModel: model, fields: fieldsDic, tableName: DatabaseTableName.user.rawValue, publicKey: publicKey, privateKey: privateKey, address: address, msgType: insertDataType, sm2UserID: sm2UserID)) { (insertResult) in

                    guard case .success(let insertResponse) = insertResult else { return }
                    do {
                        print("获取用户信息: \(String(data: insertResponse.data, encoding: .utf8)!)")
                        let model = try JSONDecoder().decode(BaseInsertModel.self, from: insertResponse.data)
                        guard model.txhash != nil else {return}

                        /// 查询结果
                        print("开始查询结果: 公钥:\(publicKey)\n私钥:\(privateKey)\n")
                        loopQueryResultState(publickeyStr: publicKey, privateKey: privateKey, queryTxhash: model.txhash!) { (state) in
                            if state == true {
                                SwiftMBHUD.dismiss()
                                let vc = HomeViewController()
                                let nav = BaseNavigationController.init(rootViewController: vc)
                                UIApplication.shared.keyWindow?.rootViewController = nav
                            } else {
                                SwiftMBHUD.showError("登录失败")
                            }
                        }
                    } catch { print("插入信息错误") }
                }
            } catch {
                SwiftMBHUD.dismiss()
            }
        }
    }

}


/// 使用 Alamofire 编写的 网络请求例子
extension CreateMnemonicController {

    func alamofireRequest(token: String) {
        let url = BASEURL + GetIntegralUrl + token
        AF.request(url, method: .get, parameters: nil).response { result in
            guard let data = result.data else {return}
            let str = String(data: data, encoding: .utf8)!
            print(str)

            sleep(5)
            self.getUserInfoModel(address: UserDefault.getAddress()!,
                                  publicKey: UserDefault.getPublickey()!,
                                  privateKey: UserDefault.getPrivateKey()!)
        }
    }

    func getUserInfoModel(address: String,publicKey: String, privateKey: String) {
        let url = BASEURL + "auth/accounts/" + address
        AF.request(url, method: .get, parameters: nil).response { result in
            guard let data = result.data else {return}
//            let str = String(data: data, encoding: .utf8)!
//            print(str)
            let userModel = try? JSONDecoder().decode(ChainUserModel.self, from: data)
            self.alamofireInsertData(userModel: userModel!, address: address, privateKey: privateKey, publicKey: publicKey)
        }
    }

    func alamofireInsertData(userModel:ChainUserModel,address: String,privateKey: String,publicKey: String){
        let url = BASEURL + "txs"
        let fields: [String : Any] = ["name":"aa",
                                      "age":"",
                                      "dbchain_key":address,
                                      "sex":"",
                                      "status":"",
                                      "photo":"",
                                      "motto":""]
        // 组装签名数据
        let signStr = Sm2ComposeSigner.shared.composeSignMessage(usermodel: userModel,
                                                                 fields: fields,
                                                                 appcode: APPCODE,
                                                                 chainid: Chainid,
                                                                 address: address,
                                                                 tableName: "user",
                                                                 privateKey: privateKey,
                                                                 sm2SignUserID: "1234567812345678",
                                                                 msgType: "dbchain/InsertRow")
        // 最终提交验证数据
        let parmeters = Sm2ComposeSigner.shared.sortedSignStr(publickStr: publicKey, signature: signStr)

        AF.request(url, method: .post, parameters: parmeters,encoding: JSONEncoding.default).response { result in
            guard let data = result.data else {return}
            let str = String(data: data, encoding: .utf8)!
            print(str)

            let dic = str.toDictionary()
            self.alamofireLoopRequest(address: address, privateKey: privateKey, publicKey: publicKey, txhash: dic["txhash"]! as! String)
        }
    }


    func alamofireLoopRequest(address: String,privateKey: String,publicKey: String,txhash: String) {
        // 定时器名称
        let timerNameStr = "VerificationHash"
        // 轮询次数
        var waitTime = 15

        // 调用 ios-client-sm2 中已有的定时器 Sm2GCDTimer 循环查询 txhash 的结果
        Sm2GCDTimer.shared.scheduledDispatchTimer(WithTimerName: timerNameStr, timeInterval: 1, queue: .main, repeats: true) {
            // 循环一次 轮询次数便减少一次
            waitTime -= 1
            guard waitTime >= 0 else {
                /// 倒计时结束时. 停止当前的计时器
                Sm2GCDTimer.shared.cancleTimer(WithTimerName: timerNameStr)
                return
            }

            let token = Sm2Token.shared.createAccessToken(privateKeyStr: privateKey, publikeyStr: publicKey)
            /// 轮询 txhash 的 url. 拼接 Token 与待查询结果的 txhash
            let url = BASEURL + "dbchain/tx-simple-result/\(token)/\(txhash)"

            /// 发送 GET 请求
            AF.request(url, method: .get, parameters: nil).response { result in
                guard let data = result.data else {return}
                let str = String(data: data, encoding: .utf8)!
                print("轮询次数:\(waitTime) 轮询结果: \(str)")

                /// 判断返回结果是否为JSON, 不是JSON说明已经失败, 取消计时器
                guard str.isjsonStyle() else {
                    Sm2GCDTimer.shared.cancleTimer(WithTimerName: timerNameStr)
                    return
                }

                let dic = str.toDictionary()
                /// 判断结果
                if dic["error"] != nil {

                    print("新增失败!")
                    Sm2GCDTimer.shared.cancleTimer(WithTimerName: timerNameStr)

                } else {

                    let result = dic["result"] as? [String: Any]
                    let state = result?["state"]

                    if state as! String == "success" {

                        print("新增成功!")
                        Sm2GCDTimer.shared.cancleTimer(WithTimerName: timerNameStr)

                    } else if state as! String == "pending" {

                        // 循环至最后一次仍然为 pending 时, 认为该条数据已新增失败
                        if waitTime == 0 { print("新增失败!") }

                    } else {

                        print("超时! 新增失败!")
                        Sm2GCDTimer.shared.cancleTimer(WithTimerName: timerNameStr)
                    }
                }
            }
        }
    }

    /// 查询整张表数据
    func alamofireQueryTableList(privateKey: String,publicKey: String,appcode: String){

        let token = Sm2Token.shared.createAccessToken(privateKeyStr: privateKey, publikeyStr: publicKey)
        /// 需要查询的表名
        let methodStr = Sm2Query().assembleQueryTableListEncodeString(tableName: "blogs")
        /// 拼接URL
        let url = BASEURL + "dbchain/querier/\(token)/\(appcode)/\(methodStr)"

        /// 发送 GET 请求
        AF.request(url, method: .get, parameters: nil).response { result in
            guard let data = result.data else {return}
            let str = String(data: data, encoding: .utf8)!
            print("返回数据:\(str)")
        }
    }

    func alamofireQueryOneData(privateKey: String,publicKey: String,appcode: String){
        let token = Sm2Token.shared.createAccessToken(privateKeyStr: privateKey, publikeyStr: publicKey)

        let fields: [String: Any] = ["id":"4"]

        let methodStr = Sm2Query().assembleConditionQueryEncodeString(tableName: "blogs", fieldDic: fields)
        /// 拼接URL
        let url = BASEURL + "dbchain/querier/\(token)/\(appcode)/\(methodStr)"
        /// 发送 GET 请求
        AF.request(url, method: .get, parameters: nil).response { result in
            guard let data = result.data else {return}
            let str = String(data: data, encoding: .utf8)!
            print("返回数据:\(str)")
        }
    }

}
