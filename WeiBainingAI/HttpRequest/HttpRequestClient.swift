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
    /// 助手配置信息
    var getHomeAllAssistant: @Sendable () async throws -> [SupportAssistantModel]
    /// 获取分享数据
    var getShareData: @Sendable () async throws -> MoreShareModel
    /// 发送聊天消息
    var sendMessage: @Sendable (_ chatConfig: (String, ChatRequestConfigMacro),
                                _ messageList: [MessageItemDb]) async throws -> DataStreamTask
    /// 请求首页的配置接口
    var requestHomeConfig: @Sendable () async throws -> HomeConfigModel
    /// 获取本地缓存用户信息
    var currentUserProfile: @Sendable () async throws -> UserProfileModel
    /// 得到一个用户的金币总数
    var getByOwner: @Sendable () async throws -> Int
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
            getHomeAllAssistant: {
                try await handler.getHomeAllAssistant()
            },
            getShareData: {
                try await handler.getShareData()
            },
            sendMessage: { chatConfig, messageList in
                try await handler.seedMessage(chatConfig, messageList)
            },
            requestHomeConfig: {
                try await handler.requestHomeConfig()
            },
            currentUserProfile: {
                if let profile = await handler.userProfile {
                    return profile
                } else {
                    return try await handler.getNewUserProfile()
                }
            },
            getByOwner: {
                try await handler.getByOwner()
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
