//
//  MessageListClient.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/2.
//

import AVFoundation
import ComposableArchitecture
import Dependencies
import Logging
import Speech
import SwiftUI
import UIKit
import WCDB

struct MessageListClient {
    /// 加载聊天请求配置
    var loadReqeustConfig: @Sendable () async -> ChatRequestConfigMacro
    /// 保存聊天请求配置
    var saveReqeustConfig: @Sendable (ChatRequestConfigMacro) async throws -> Bool
    /// 检测是否有语音权限
    var checkSpeechAuth: @Sendable () async -> Bool
    /// 开始语音转文字
    var startVoiceToText: @Sendable () async throws -> AsyncThrowingStream<String, Error>
    /// 停止语音转文字
    var stopVoiceRecognition: @Sendable () async -> Void
    /// 处理流返回的数据
    var handleStreamData: @Sendable (_ chatConfig: (String, ChatRequestConfigMacro),
                                     _ messageList: [MessageItemDb]) async throws -> AsyncThrowingStream<String, Error>
}

extension MessageListClient: DependencyKey {
    static var liveValue: MessageListClient {
        @Dependency(\.httpClient) var httpClient

        let speechEngine = SpeechEngineActor()

        return Self {
            if let saveData = UserDefaults.standard.data(forKey: "CachedChatRequestConfig") {
                if let loadConfig = try? JSONDecoder().decode(ChatRequestConfigMacro.self, from: saveData) {
                    return loadConfig
                } else {
                    return ChatRequestConfigMacro.defaultConfig()
                }
            } else {
                return ChatRequestConfigMacro.defaultConfig()
            }
        } saveReqeustConfig: {
            let saveData = try JSONEncoder().encode($0)
            UserDefaults.standard.set(saveData, forKey: "CachedChatRequestConfig")
            return true
        } checkSpeechAuth: {
            let recordingPermission = await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    if granted {
                        debugPrint("requestRecordPermission: granted")
                        continuation.resume(returning: true)
                    } else {
                        debugPrint("requestRecordPermission: unknown")
                        continuation.resume(returning: false)
                    }
                }
            }
            let speechPermission = await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    switch status {
                    case .authorized:
                        debugPrint("requestAuthorization: authorized")
                        continuation.resume(returning: true)
                    default:
                        debugPrint("requestAuthorization: unknown")
                        continuation.resume(returning: false)
                    }
                }
            }
            return recordingPermission && speechPermission

        } startVoiceToText: {
            await speechEngine.startVoiceToText()
        } stopVoiceRecognition: {
            await speechEngine.stopVoiceRecognition()
        } handleStreamData: { chatConfig, messageList in
            AsyncThrowingStream<String, Error> { continution in
                Task {
                    do {
                        let streamTask = try await httpClient.sendMessage(chatConfig, messageList)
                        for try await value in streamTask.streamingStrings() {
                            if value.value != nil {
                                switch String(describing: value.value ?? "") {
                                case ChatErrorMacro.success.rawValue:
                                    continution.yield(ChatErrorMacro.success.rawValue)
                                    continution.finish()
                                case ChatErrorMacro.loginNeed.rawValue:
                                    continution.yield(ChatErrorMacro.loginNeed.description)
                                    continution.finish()
                                case ChatErrorMacro.notEnoughUsed.rawValue:
                                    continution.yield(ChatErrorMacro.notEnoughUsed.description)
                                    continution.finish()
                                case ChatErrorMacro.invalidSign.rawValue,
                                     ChatErrorMacro.invalidRequest.rawValue,
                                     ChatErrorMacro.qpsLimit.rawValue,
                                     ChatErrorMacro.msgInvalid.rawValue,
                                     ChatErrorMacro.msgParamMissing.rawValue,
                                     ChatErrorMacro.msgParamNumInvalid.rawValue,
                                     ChatErrorMacro.msgRoleInvalid.rawValue,
                                     ChatErrorMacro.paramModleInvalid.rawValue,
                                     ChatErrorMacro.unknownError.rawValue:
                                    continution.yield(ChatErrorMacro.unknownError.rawValue)
                                    continution.finish()
                                default:
                                    // 每次发送消息到流中
                                    continution.yield(value.value ?? "")
                                }
                            } else {
                                continution.yield(ChatErrorMacro.unknownError.rawValue)
                                continution.finish()
                            }
                        }
                    } catch {
                        continution.yield(ChatErrorMacro.unknownError.rawValue)
                        continution.finish()
                    }
                }
            }
        }
    }
}

extension MessageListClient: TestDependencyKey {
    static var previewValue: MessageListClient {
        return Self(
            loadReqeustConfig: {
                ChatRequestConfigMacro.defaultConfig()
            },
            saveReqeustConfig: { _ in
                true
            },
            checkSpeechAuth: {
                true
            },
            startVoiceToText: {
                AsyncThrowingStream<String, Error> { continuation in
                    continuation.yield("我是语音转文字的结果")
                    continuation.finish()
                }
            }, stopVoiceRecognition: {}, handleStreamData: { _, _ in
                AsyncThrowingStream<String, Error> { continuation in
                    continuation.yield("我是聊天结果")
                    continuation.yield(ChatErrorMacro.success.rawValue)
                    continuation.finish()
                }
            }
        )
    }

    static var testValue: MessageListClient {
        Self(
            loadReqeustConfig: unimplemented("\(Self.self).loadReqeustConfig"),
            saveReqeustConfig: unimplemented("\(Self.self).saveReqeustConfig"),
            checkSpeechAuth: unimplemented("\(Self.self).checkSpeechAuth"),
            startVoiceToText: unimplemented("\(Self.self).startVoiceToText"),
            stopVoiceRecognition: unimplemented("\(Self.self).stopVoiceRecognition"),
            handleStreamData: unimplemented("\(Self.self).handleStreamData")
        )
    }
}

extension DependencyValues {
    var msgListClient: MessageListClient {
        get { self[MessageListClient.self] }
        set { self[MessageListClient.self] = newValue }
    }
}
