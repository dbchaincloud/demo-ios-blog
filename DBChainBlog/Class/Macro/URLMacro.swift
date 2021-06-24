//
//  URLMacro.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/23.
//

import UIKit
import Foundation

/// 生产环境
//let BASEURL : String = "https://chain-ytbox.dbchain.cloud/relay/"
//var Chainid : String = "ytbox"
//var APPCODE : String = "8BSMXFVQ5W"


/// 测试  BBJWQCPJLF
//let BASEURL : String = "http://192.168.0.19/relay/"
//var Chainid : String = "testnet"
//var APPCODE : String = "7Z3EFBMTPG"


//2KDWVWXNLB
// 123   本地测试
//let BASEURL : String = "http://192.168.0.19:3001/relay/"
//var Chainid : String = "testnet"
//var APPCODE : String = "JYYZBFASUR"

/// 线上沙盒环境
let BASEURL : String = "https://controlpanel.dbchain.cloud/relay/"
var Chainid : String = "testnet"
var APPCODE : String = "4HQJA8CUUF"

/// 获取用户信息
var GetUserDataURL = BASEURL + "auth/accounts/"
/// 插入信息
var InsertDataURL = BASEURL + "txs"
/// 查询
var QueryDataUrl = BASEURL + "dbchain/querier/"
/// 上传数据
var UploadFileURL = BASEURL + "dbchain/upload/"
/// 图片下载地址
var DownloadFileURL: String = BASEURL + "ipfs/"
/// 新注册账号获取权限
var GetIntegralUrl = BASEURL + "dbchain/oracle/new_app_user/"
/// 内购 发起订单   Payment
var PaymentIssueOrderURL = BASEURL + "dbchain/oracle/applepay/"
/// 查询提交订单是否成功
var QueryApplePayOrderSuccessStatusURL = BASEURL + "dbchain/oracle/submit_order_status/"
/// 查询 支付订单
var QueryApplePayOrderURL = BASEURL + "dbchain/oracle/payment_query/"

