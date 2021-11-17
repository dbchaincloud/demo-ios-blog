//
//  IPALoopQuery.swift
//  DBChainBlog
//
//  Created by iOS on 2021/11/16.
//

import Foundation
import GMChainSm2

/// 循环查询插入数据的结果状态
/// - Parameters:
///   - loopTime: 循环查询的时间和次数, 默认15秒.  超时即返回失败
///   - publickeyStr: 公钥字符串
///   - privateKey: 私钥字符串
///   - queryTxhash: 需要查询插入结果是否成功的哈希
///   - return: false 失败 true 成功
func loopQueryResultState(loopTime: Int = 15,publickeyStr: String, privateKey: String, queryTxhash: String,verifiSuccessBlock:@escaping(_ states: Bool) -> Void) {

    var waitTime = loopTime
    let token = Sm2Token.shared.createAccessToken(privateKeyStr: privateKey, publikeyStr: publickeyStr)
    Sm2GCDTimer.shared.scheduledDispatchTimer(WithTimerName: "VerificationHash", timeInterval: 1, queue: .main, repeats: true) {
        waitTime -= 1
        if waitTime > 0 {
            IPAProvider.request(NetworkAPI.verificationHash(token: token, txhash: queryTxhash)) { (verificationData) in
                guard case .success(let verificationResponse) = verificationData else { return }
                do {
                    let json = try verificationResponse.mapJSON() as! NSDictionary
                    print("查询倒计时: \(waitTime) \n结果:\(json)\n")
                    if json["error"] != nil {
                        verifiSuccessBlock(false)
                        Sm2GCDTimer.shared.cancleTimer(WithTimerName: "VerificationHash")
                    } else {
                        let result = json["result"] as? [String: Any]
                        let state = result?["state"]
                        if state as! String == "success" {
                            verifiSuccessBlock(true)
                            Sm2GCDTimer.shared.cancleTimer(WithTimerName: "VerificationHash")
                        } else if state as! String == "pending" {
                            print("继续等待:\(waitTime)")
                        } else {
                            verifiSuccessBlock(false)
                            Sm2GCDTimer.shared.cancleTimer(WithTimerName: "VerificationHash")
                        }
                    }
                }
                catch {
                    print("查询倒计时解析json失败!!!")
                    Sm2GCDTimer.shared.cancleTimer(WithTimerName: "VerificationHash")
                    verifiSuccessBlock(false)
                }
            }
        } else {
            Sm2GCDTimer.shared.cancleTimer(WithTimerName: "VerificationHash")
            verifiSuccessBlock(false)
            print("查询倒计时结束!!!! 无结果.")
        }
    }
}
