//
//  HttpParserHandler.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/23.
//

import Alamofire
import ComposableArchitecture
import CryptoSwift
import Logging
import UIKit

struct HttpConst {
    static var cryptoKey = "71d2468b64ea4daaec40472ee061161c"
    static var aesKey = "d828e59dfd99eace879266491b6bbe00"
    static var aseIv = "d828e59dfd99eace"
    static var hostApi = URL(string: "https://aichat.mycolordiary.com/s/api")!
    static var chatApi = URL(string: "https://aichat.mycolordiary.com/s/genius")!
    static let hostImg = URL(string: "https://aichat.mycolordiary.com/s/img")!
    static var appName: String = "WeiBainingAI"
    // 请求接口cmd
    static let getServerForiOS = "Secret.getServerForiOS"
    static let getServerTime = "Secret.getServerTime"
    static let getLoginAccount = "Secret.login"
    static let getLoginInfo = "UserQQ.getLoginInfo"
    static let payConfList = "UserVip.getPayConfList"
    static let payAppStoreV2 = "UserVip.payAppStoreV2"
    static let payAppleV2 = "UserVip.payAppleV2"
    static let chargeVipV2 = "UserVip.chargeVipV2"
    static let uploadImage = "ColorizeServer.uploadImage"
    static let genTxt2imgTask = "ColorizeServer.genTxt2imgTask"
    static let getTxt2imgResult = "ColorizeServer.getTxt2imgResult"
    static let getHomeAll = "ChatTool.getHomeAll"
    static let getShareData = "ChatTool.getShareData"
    static let requestChat = "ChatTool.chat"
    // 静态地址
    static let privateUrl = URL(string: "https://cloudsail.notion.site/66345d0752c64febb32b71d50f2a4a19?pvs=4")!
    static let usageUrl = URL(string: "https://cloudsail.notion.site/ChatAID-3f8d8fdfa72f4596b75c59b719a8ee3b?pvs=4")!
    static let feedbackUrl = URL(string: "https://cloudsail.notion.site/875c079245c44139b77e6958120cec76?pvs=4")!
}

class HttpParserHandler: DataPreprocessor {
    let aesKey: String
    let aesIv: String

    init(aesKey: String, aesIv: String) {
        self.aesKey = aesKey
        self.aesIv = aesIv
    }

    func preprocess(_ data: Data) throws -> Data {
        return try data.decrypt(aesKey: aesKey, aesIv: aesIv)
    }
}

private extension Data {
    func decrypt(aesKey: String, aesIv: String) throws -> Data {
        guard let aesKey = aesKey.data(using: .utf8)?.sha256().bytes,
              let aes = try? AES(key: aesKey, blockMode: CBC(iv: aesIv.bytes)),
              let base64DecodedData = Data(base64Encoded: self),
              let decryptData = try? base64DecodedData.decrypt(cipher: aes)
        else {
            throw HttpErrorHandler.decodingFailed
        }
        #if DEBUG
            if let json = try? JSONSerialization.jsonObject(with: decryptData),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let string = String(data: pretty, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                Logger(label: "").info("返回内容===>\(string)")
            }
        #else
        #endif
        return decryptData
    }
}
