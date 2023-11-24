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
