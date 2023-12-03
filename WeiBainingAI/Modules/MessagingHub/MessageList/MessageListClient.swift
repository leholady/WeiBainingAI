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

struct MessageListClient {
    /// 加载聊天请求配置
    var loadReqeustConfig: @Sendable () async -> ChatRequestConfigMacro
    /// 保存聊天请求配置
    var saveReqeustConfig: @Sendable (ChatRequestConfigMacro) async throws -> Bool
    /// 从数据库加载历史会话话题
    var loadLocalTopics: @Sendable (_ userId: Int) async -> [TopicHistoryModel]
    /// 从数据库加载历史消息
    var loadLocalMessages: @Sendable (_ topic: TopicHistoryModel) async -> [MessageItemModel]
    /// 保存单项消息到数据库
    var saveSingleMessage: @Sendable (_ msg: MessageItemModel) async throws -> Bool
    /// 检测是否有语音权限
    var checkSpeechAuth: @Sendable () async -> Bool
    /// 开始语音转文字
    var startVoiceToText: @Sendable () async throws -> AsyncThrowingStream<String, Error>
}

extension MessageListClient: DependencyKey {
    static var liveValue: MessageListClient {
        previewValue
    }
}

extension MessageListClient: TestDependencyKey {
    static var previewValue: MessageListClient {
        Self {
            if let saveData = UserDefaults.standard.data(forKey: "CachedChatRequestConfig") {
                if let loadConfig = try? JSONDecoder().decode(ChatRequestConfigMacro.self, from: saveData) {
                    return loadConfig
                } else {
                    return ChatRequestConfigMacro.defaultConfig()
                }
            } else {
                return ChatRequestConfigMacro.defaultConfig()
            }
        } saveReqeustConfig: { requestConfig in
            let saveData = try JSONEncoder().encode(requestConfig)
            UserDefaults.standard.set(saveData, forKey: "CachedChatRequestConfig")
            return true
        } loadLocalTopics: { userId in
            [
                TopicHistoryModel(userId: userId, timestamp: Date(),
                                  topic: "写一篇关于二手车买卖市场趋势的调查报告",
                                  reply: "根据最近几年的统计数据分析,国内二手车交易市场持续活跃,交易量稳步上升。报告预测未来5年二手车交易额还将保持较快增长态势。主要原因在于..."),

                TopicHistoryModel(userId: userId, timestamp: Date(),
                                  topic: "写一首反映工业文明的现代叙事诗",
                                  reply: "铁与铜构成 agora 的框架,玻璃反射着太阳的光辉。烟囱向天空喷泄着,工人们操作着,机器轰鸣作响..."),

                TopicHistoryModel(userId: userId, timestamp: Date(),
                                  topic: "给喜欢登山的朋友写一封生日贺卡",
                                  reply: "每当看到高山,总会想起你激动而专注的神情。每一座峰顶都是你的生日礼物,愿你像攀登山峰那样勇往直前,从未放弃梦想!")
            ]
        } loadLocalMessages: { topic in
            [
                MessageItemModel(topicId: topic.id, isSender: true,
                                 content: "写一首古代散文诗歌",
                                 msgState: .success,
                                 timestamp: Date()),
                MessageItemModel(topicId: topic.id, isSender: false,
                                 content: "在昔日的土地上，影子舞动，时间展开古老的恍惚，一个故事展开，很久以前的日子，低声吟唱，将永远持续。在月亮的空灵光芒下，古老的智慧，赋予的秘密，星星的交响曲 点燃黑夜，引导灵魂穿越古老力量的国度。",
                                 msgState: .success,
                                 timestamp: Date()),

                MessageItemModel(topicId: topic.id, isSender: true,
                                 content: "写一份关于太空旅行的市场分析报告",
                                 msgState: .success,
                                 timestamp: Date()),

                MessageItemModel(topicId: topic.id, isSender: false,
                                 content:
                                 """
                                     近年来,随着商业航天公司的崛起和旅游业的发展,太空旅行市场势头正猛。本报告从市场规模、主要参与者、消费者需求、法律监管等多个角度分析了太空旅行市场的发展现状及未来趋势。

                                     根据预测,到2030年,太空旅行市场规模将达到100亿美元。目前SpaceX、Blue Origin及Virgin Galactic是行业的主要参与者,正在开发可重复使用的次轨道太空载具。随着载人航天飞机的运营成本不断下降,预计每年将有数万游客前往太空旅行。
                                 """,
                                 msgState: .success,
                                 timestamp: Date())
            ]
        } saveSingleMessage: { _ in
            true
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
        }
        startVoiceToText: {
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
        }
    }

    static var testValue: MessageListClient {
        Self(
            loadReqeustConfig: unimplemented("\(Self.self).loadReqeustConfig"),
            saveReqeustConfig: unimplemented("\(Self.self).saveReqeustConfig"),
            loadLocalTopics: unimplemented("\(Self.self).loadLocalTopics"),
            loadLocalMessages: unimplemented("\(Self.self).loadLocalMessages"),
            saveSingleMessage: unimplemented("\(Self.self).saveSingleMessage"),
            checkSpeechAuth: unimplemented("\(Self.self).checkSpeechAuth"),
            startVoiceToText: unimplemented("\(Self.self).startVoiceToText")
        )
    }
}

extension DependencyValues {
    var msgListClient: MessageListClient {
        get { self[MessageListClient.self] }
        set { self[MessageListClient.self] = newValue }
    }
}
