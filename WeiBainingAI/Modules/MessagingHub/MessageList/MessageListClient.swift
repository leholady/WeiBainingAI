//
//  MessageListClient.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/2.
//

import Dependencies
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
        }
    }

    static var testValue: MessageListClient {
        Self(
            loadReqeustConfig: unimplemented("\(Self.self).loadReqeustConfig"),
            saveReqeustConfig: unimplemented("\(Self.self).saveReqeustConfig"),
            loadLocalTopics: unimplemented("\(Self.self).loadLocalTopics"),
            loadLocalMessages: unimplemented("\(Self.self).loadLocalMessages"),
            saveSingleMessage: unimplemented("\(Self.self).saveSingleMessage")
        )
    }
}

extension DependencyValues {
    var msgListClient: MessageListClient {
        get { self[MessageListClient.self] }
        set { self[MessageListClient.self] = newValue }
    }
}