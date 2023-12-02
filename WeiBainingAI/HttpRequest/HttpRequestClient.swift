//
//  HttpRequestClient.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/23.
//

import Alamofire
import Dependencies
import Logging
import UIKit

struct HttpRequestClient {
    /// 获取服务器时间戳
    var serverTimestamp: @Sendable () async throws -> Int
    /// 登录用户账号
    var loginUserAccount: @Sendable () async throws -> UserProfileModel
    /// 获取用户配置
    var getNewUserProfile: @Sendable () async throws -> UserProfileModel
    /// 上传图片获取Sign
    var uploadImageSign: @Sendable (Data) async throws -> String
    /// 生成AI自动创作图像任务-异步
    var txtToImageTask: @Sendable (TextImageTaskConfigureModel) async throws -> TextImageTaskResultModel
    /// 获取AI自动创作图像结果
    var txtToImageResult: @Sendable (String) async throws -> TextImageTaskResultModel
    /// 发送聊天消息
    var sendMessage: @Sendable (String, _ config: ChatRequestConfigMacro) async throws -> AsyncThrowingStream<String, Error>
    /// 获取本地缓存用户信息
    var currentUserProfile: @Sendable () async throws -> UserProfileModel
}

extension HttpRequestClient: DependencyKey {
    static var liveValue: HttpRequestClient {
        let handler = HttpRequestHandler()
        return Self(
            serverTimestamp: {
                try await handler.getServerTimestamp()
            },
            loginUserAccount: {
                try await handler.loginUserAccount()
            },
            getNewUserProfile: {
                try await handler.getNewUserProfile()
            },
            uploadImageSign: {
                try await handler.uploadImageSign($0)
            },
            txtToImageTask: {
                try await handler.txtToImageTask($0)
            },
            txtToImageResult: {
                try await handler.txtToImageResult($0)
            },
            sendMessage: { message, config in
                AsyncThrowingStream<String, Error> { continution in
                    Task {
                        do {
                            let streamTask = try await handler.seedMessage(message, config)
                            for try await value in streamTask.streamingStrings() {
                                if let result = value.value {
                                    Logger(label: "stream value ===>").info("\(value.value ?? "")")
                                    switch String(describing: value.value ?? "") {
                                    case ChatErrorMacro.success.rawValue:
                                        continution.finish()
                                    case ChatErrorMacro.loginNeed.rawValue:
                                        continution.finish(throwing: HttpErrorHandler.failedWithServer(ChatErrorMacro.invalidSign.description))
                                    case ChatErrorMacro.notEnoughUsed.rawValue:
                                        continution.finish(throwing: HttpErrorHandler.failedWithServer(ChatErrorMacro.invalidRequest.description))
                                    case ChatErrorMacro.invalidSign.rawValue,
                                         ChatErrorMacro.invalidRequest.rawValue,
                                         ChatErrorMacro.qpsLimit.rawValue,
                                         ChatErrorMacro.msgInvalid.rawValue,
                                         ChatErrorMacro.msgParamMissing.rawValue,
                                         ChatErrorMacro.msgParamNumInvalid.rawValue,
                                         ChatErrorMacro.msgRoleInvalid.rawValue,
                                         ChatErrorMacro.unknownError.rawValue:
                                        let errorMacro = ChatErrorMacro(rawValue: value.value ?? "")
                                        continution.finish(throwing: HttpErrorHandler.failedWithServer(errorMacro?.description))
                                    default:
                                        // 每次发送消息到流中
                                        continution.yield(message)
                                    }
                                } else {
                                    continution.finish(throwing: HttpErrorHandler.failedWithServer(nil))
                                }
                            }
                        } catch {
                            continution.finish(throwing: error)
                        }
                    }
                }
            },
            currentUserProfile: {
                if let profile = await handler.userProfile {
                    return profile
                } else {
                    return try await handler.getNewUserProfile()
                }
            }
        )
    }
}

extension DependencyValues {
    var httpClient: HttpRequestClient {
        get {
            self[HttpRequestClient.self]
        }
        set {
            self[HttpRequestClient.self] = newValue
        }
    }
}
