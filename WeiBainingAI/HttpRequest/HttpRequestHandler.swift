//
//  HttpRequestHandler.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/23.
//  网络请求处理

import Alamofire
import CryptoSwift
import DeviceKit
import KeychainSwift
import Logging
import UIKit

// MARK: - 请求session处理

actor HttpRequestHandler {
    /// 用户信息
    private var userProfile: UserProfileModel?
    /// 时间戳
    private var timestamp: (serverTime: Int, awakTime: Int) = (0, 0)

    /// 用户钥匙串唯一标识
    var userUniqueId: String {
        if let identifier = keychain.get(uniqueIdKey) {
            return identifier
        } else {
            let uuidString = UUID().uuidString
            keychain.set(uuidString, forKey: uniqueIdKey)
            return uuidString
        }
    }

    private var bundleId: String {
        "\(Bundle.main.infoDictionary?["CFBundleExecutable"] ?? "")"
    }

    private var uniqueIdKey: String {
        "\(bundleId)_CacheUerUniqueId"
    }

    private let keychain = KeychainSwift(keyPrefix: "\(Bundle.main.infoDictionary?["CFBundleExecutable"] ?? "")")

    /// 请求session
    private let session: Alamofire.Session = {
        let eventMonitor = ClosureEventMonitor()
        eventMonitor.requestDidCompleteTaskWithError = { request, _, _ in
        }
        return Alamofire.Session(eventMonitors: [eventMonitor])
    }()

    /// 基础参数
    private func basicParameters(parameters: [String: Any]) -> [String: Any] {
        var parameter = parameters
        parameter["appName"] = HttpConst.appName
        parameter["_sys"] = "iOS"
        parameter["_lv"] = "2"
        parameter["_channel"] = "App Store"
        parameter["_sysVersion"] = "\(Device.current.systemVersion ?? "unknown")"
        parameter["_model"] = "\(Device.identifier)(\(Device.current.description))"
        parameter["_version"] = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown version"
        parameter["_lang"] = Locale.preferredLanguages.first ?? (Locale.current.languageCode ?? "unknown")
        parameter["_country"] = Locale.current.regionCode ?? "unknown"
        var sortedParameters = parameter
            .sorted {
                $0.key < $1.key
            }
            .map {
                "\($0.key)=\($0.value)"
            }
        sortedParameters.append("key=\(HttpConst.cryptoKey)")
        let sign = sortedParameters.joined(separator: "::")
        parameter["_sign"] = sign.md5()
        return parameter
    }

    /// 基础请求
    private func baseRequest<Response: Codable>(parameters: [String: Any] = [:]) async throws -> Response {
        let finalParameters = basicParameters(parameters: parameters)
        #if DEBUG
            if let jsonData = try? JSONSerialization.data(withJSONObject: finalParameters, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            {
                Logger(label: "").info("请求参数===>\(jsonString)")
            }
        #else
        #endif
        let dataTask = session
            .request(
                HttpConst.hostApi,
                method: .post,
                parameters: finalParameters
            ) { urlRequest in
                urlRequest.timeoutInterval = 15
            }
            .serializingDecodable(
                Response.self, automaticallyCancelling: true,
                dataPreprocessor: HttpParserHandler(aesKey: HttpConst.aesKey, aesIv: HttpConst.aseIv),
                decoder: JSONDecoder()
            )
        do {
            let dataTaskValue = try await dataTask.value
            return dataTaskValue
        } catch {
            throw HttpErrorHandler.failure(error)
        }
    }

    /// 基础类请求
    private func requestTask<T: Codable>(cmd: String, parameters: [String: Any] = [:]) async throws -> T {
        var params = parameters
        params.updateValue(cmd, forKey: "cmd")
        params.updateValue(UUID().uuidString.md5(), forKey: "_nonce")

        let serverTime = timestamp.serverTime
        if serverTime == 0 {
            let serverTime = try await getServerTimestamp()
            timestamp = (serverTime, Int(Date().timeIntervalSince1970))
            params.updateValue(serverTime, forKey: "_time")
        } else {
            params.updateValue(serverTime + (Int(Date().timeIntervalSince1970) - timestamp.awakTime), forKey: "_time")
        }

        let taskRespons: HttpResponseHandler<T> = try await baseRequest(parameters: params)
        switch taskRespons.err {
        case .success where taskRespons.res != nil:
            return taskRespons.res!
        case .needLogin:
//            WebConnectorBridger.profileModel = try await loginUserAccount()
            return try await requestTask(cmd: cmd, parameters: params)
        default:
            throw HttpErrorHandler.failedWithServer(taskRespons.errUserMsg)
        }
    }
}

// MARK: - 业务请求

extension HttpRequestHandler {
    /// 获取时间戳
     func getServerTimestamp() async throws -> Int {
        let response: HttpResponseHandler<HttpResponseTimestamp> = try await baseRequest(
            parameters: [
                "cmd": HttpConst.getServerTime,
                "_nonce": UUID().uuidString.md5(),
            ]
        )
        return response.res?.timestamp ?? Int(Date().timeIntervalSince1970)
    }

    /// 登录用户账号
    func loginUserAccount() async throws -> UserProfileModel {
        let parameters: [String: Any] = [
            "thirdType": "VISITOR",
            "thirdId": userUniqueId,
        ]
        let profile: UserProfileModel = try await requestTask(
            cmd: HttpConst.getLoginAccount,
            parameters: parameters
        )
        userProfile = profile
        return profile
    }

    /// 获取用户信息
    func getNewUserProfile() async throws -> UserProfileModel {
        do {
            let profile: UserProfileModel = try await requestTask(
                cmd: HttpConst.getLoginInfo,
                parameters: [:]
            )
            userProfile = profile
            if profile.isLogin == true {
                return profile
            } else {
                return try await loginUserAccount()
            }
        } catch {
            throw HttpErrorHandler.failedWithServer("获取用户信息失败")
        }
    }
}
