//
//  HttpErrorHandler.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/23.
//

import UIKit

enum HttpErrorHandler: Error {
    case failedWithServer(String?)
    case failure(Error)
    case decodingFailed
    case noResponse
}

enum ChatErrorMacro: String {
    /// 以下是流式响应的错误信息
    case invalidSign = "[invalidSign]" // 签名错误
    case loginNeed = "[loginNeed]" // 需要登录
    case invalidRequest = "[invalidRequest]" // 请求无效
    case qpsLimit = "[qpsLimit]" //  qps限制
    case notEnoughUsed = "[notEnoughUsed]" //  使用次数不足
    case msgInvalid = "[messagesInvalid]" // messages参数不是json 或者成员个数不是基数
    case msgParamMissing = "[messages.paramMissing]" // messages参数缺少 content或缺少 role
    case msgParamNumInvalid = "[messages.paramNumInvalid]" // messages参数成员数量不能大2
    case msgRoleInvalid = "[messages.roleInvalid]" // messages参数中角色不正确。 依次为 user、assistant
    case unknownError = "[error]" // 异常错误
    case success = "[DONE]" // 响应完毕

    var description: String {
        switch self {
        case .invalidSign:
            return "签名错误"
        case .loginNeed:
            return "需要登录"
        case .invalidRequest:
            return "请求无效"
        case .qpsLimit:
            return "qps限制"
        case .notEnoughUsed:
            return "使用次数不足"
        case .msgInvalid:
            return "messages参数不是json 或者成员个数不是基数"
        case .msgParamMissing:
            return "messages参数缺少 content或缺少 role"
        case .msgParamNumInvalid:
            return "messages参数成员数量不能大2"
        case .msgRoleInvalid:
            return "messages参数中角色不正确。 依次为 user、assistant"
        case .unknownError:
            return "异常错误"
        case .success:
            return "响应完毕"
        }
    }
}
