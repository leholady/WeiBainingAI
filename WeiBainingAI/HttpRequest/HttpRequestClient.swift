//
//  HttpRequestClient.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/23.
//

import Dependencies
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
