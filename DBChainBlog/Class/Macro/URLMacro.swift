//
//  URLMacro.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/23.
//   val appCode = "5APTSCPSF7"
//val baseUrl = "https://controlpanel.dbchain.cloud/relay/"
//val chainId = "testnet"

import UIKit
import Foundation

let BASEURL : String = "https://controlpanel.dbchain.cloud/relay/"
var Chainid : String = "testnet"
//var APPCODE : String = "4HQJA8CUUF"
var APPCODE : String = "5APTSCPSF7"

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


