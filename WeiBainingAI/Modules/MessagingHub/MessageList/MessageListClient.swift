//
//  MessageListClient.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/2.
//

import AVFoundation
import Dependencies
import Logging
import Speech
import UIKit
import WCDBSwift

struct MessageListClient {
    /// 加载聊天请求配置
    var loadReqeustConfig: @Sendable () async -> ChatRequestConfigMacro
    /// 保存聊天请求配置
    var saveReqeustConfig: @Sendable (ChatRequestConfigMacro) async throws -> Bool
    /// 检测是否有语音权限
    var checkSpeechAuth: @Sendable () async -> Bool
    /// 开始语音转文字
    var startVoiceToText: @Sendable () async throws -> AsyncThrowingStream<String, Error>
    /// 处理流返回的数据
    var handleStreamData: @Sendable (String, _ config: ChatRequestConfigMacro) async throws -> AsyncThrowingStream<String, Error>
}

extension MessageListClient: DependencyKey {
    static var liveValue: MessageListClient {
        @Dependency(\.httpClient) var httpClient

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
            await withCheckedContinuation { continuation in
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
        } startVoiceToText: {
            let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
            let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            let audioEngine = AVAudioEngine()
            var recognitionTask: SFSpeechRecognitionTask?

            return AsyncThrowingStream<String, Error> { continuation in
                // 建立一个AVAudioSession 用于录音
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setCategory(AVAudioSession.Category.record)
                    try audioSession.setMode(AVAudioSession.Mode.measurement)
                    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                } catch {
                    continuation.finish(throwing: NSError(domain: "audioSession properties weren't set because of an error.",
                                                          code: 0))
                }
                // 初始化RecognitionRequest，在后边我们会用它将录音数据转发给苹果服务器
                let inputNode = audioEngine.inputNode
                // 在用户说话的同时，将识别结果分批次返回
                recognitionRequest.shouldReportPartialResults = true
                // 使用recognitionTask方法开始识别。
                recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { result, error in
                    if let error = error {
                        audioEngine.stop()
                        inputNode.removeTap(onBus: 0)
                        recognitionTask?.cancel()
                        continuation.finish(throwing: error)
                    }
                    if result?.isFinal == true {
                        audioEngine.stop()
                        inputNode.removeTap(onBus: 0)
                        recognitionTask?.cancel()
                        continuation.finish()
                    }
                    continuation.yield(result?.bestTranscription.formattedString ?? "")
                })

                // 向recognitionRequest加入一个音频输入
                let recordingFormat = inputNode.outputFormat(forBus: 0)
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                    recognitionRequest.append(buffer)
                }
                audioEngine.prepare()
                do {
                    // 开始录音
                    try audioEngine.start()
                } catch {
                    print("audioEngine couldn't start because of an error.")
                }
            }
        } handleStreamData: { msg, config in
            AsyncThrowingStream<String, Error> { continution in
                Task {
                    do {
                        let streamTask = try await httpClient.sendMessage(msg, config)
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
            }, handleStreamData: { _, _ in
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
