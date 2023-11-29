//
//  MessagingClient.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/28.
//

import Dependencies
import UIKit

struct MessageAPIClient {
    /// 请求首页数据
    var requestHomeProfile: @Sendable () async throws -> [SuggestionsModel]
    /// 查询历史话题数据
    var loadHistoryTopic: @Sendable () async throws -> [TopicHistoryModel]
    /// 根据话题id，查询会话消息列表
    var loadMsgList: @Sendable (Int) async throws -> [MessageItemModel]
    /// 加载输入提示语
    var loadInputTips: @Sendable () async throws -> [String]
}

extension MessageAPIClient: DependencyKey {
    static var liveValue: MessageAPIClient {
        previewValue
    }
}

extension MessageAPIClient: TestDependencyKey {
    static var previewValue: MessageAPIClient {
        Self(
            requestHomeProfile: {
                [
                    SuggestionsModel(title: "写一份关于太空旅行的市场分析报告"),
                    SuggestionsModel(title: "写一首古代散文诗歌"),
                    SuggestionsModel(title: "给热爱旅行的妻子写一封情人节信"),
                    SuggestionsModel(title: "写一篇关于二手车买卖市场趋势的调查报告"),
                    SuggestionsModel(title: "写一首反映工业文明的现代叙事诗"),
                    SuggestionsModel(title: "给喜欢登山的朋友写一封生日贺卡"),
                    SuggestionsModel(title: "撰写一份有关虚拟现实游戏用户体验的调查分析"),
                    SuggestionsModel(title: "创作一首抒发大自然之美的田园诗歌"),
                    SuggestionsModel(title: "给一直支持你学业的老师写一封感谢信"),
                    SuggestionsModel(title: "研究一下无人机应用领域的市场前景预测")
                ]
            },
            loadHistoryTopic: {
                [
                    TopicHistoryModel(timestamp: Date(),
                                      topic: "写一篇关于二手车买卖市场趋势的调查报告",
                                      reply: "根据最近几年的统计数据分析,国内二手车交易市场持续活跃,交易量稳步上升。报告预测未来5年二手车交易额还将保持较快增长态势。主要原因在于..."),

                    TopicHistoryModel(timestamp: Date(),
                                      topic: "写一首反映工业文明的现代叙事诗",
                                      reply: "铁与铜构成 agora 的框架,玻璃反射着太阳的光辉。烟囱向天空喷泄着,工人们操作着,机器轰鸣作响..."),

                    TopicHistoryModel(timestamp: Date(),
                                      topic: "给喜欢登山的朋友写一封生日贺卡",
                                      reply: "每当看到高山,总会想起你激动而专注的神情。每一座峰顶都是你的生日礼物,愿你像攀登山峰那样勇往直前,从未放弃梦想!"),

                    TopicHistoryModel(timestamp: Date(),
                                      topic: "撰写一份有关虚拟现实游戏用户体验的调查分析",
                                      reply: "根据对210名虚拟现实游戏玩家的调研,超过85%的受访者对当前主流VR游戏的用户体验表示满意。本研究分析了虚拟现实游戏在视觉、听觉、交互等多方面的优势..."),

                    TopicHistoryModel(timestamp: Date(),
                                      topic: "创作一首抒发大自然之美的田园诗歌",
                                      reply: "绿草如茵,花儿绽放。坐在草坪上,聆听鸟语花香。微风轻拂,树叶婆娑。汇成一曲田园之歌,歌颂大自然赐予的美好时光。"),

                    TopicHistoryModel(timestamp: Date(),
                                      topic: "给一直支持你学业的老师写一封感谢信",
                                      reply: "您的教导与帮助让我受益匪浅,学业上的每一个进步都离不开您的指导。我由衷地感谢您多年来对我的鼓励与支持。您就是我心目中最伟大的老师!")
                ]
            },
            loadMsgList: { userId in
                [
                    MessageItemModel(userId: userId,
                                     isSender: true,
                                     content: "写一首古代散文诗歌",
                                     msgState: .success,
                                     timestamp: Date()),
                    MessageItemModel(userId: userId,
                                     isSender: false,
                                     content: "在昔日的土地上，影子舞动，时间展开古老的恍惚，一个故事展开，很久以前的日子，低声吟唱，将永远持续。在月亮的空灵光芒下，古老的智慧，赋予的秘密，星星的交响曲 点燃黑夜，引导灵魂穿越古老力量的国度。",
                                     msgState: .success,
                                     timestamp: Date()),

                    MessageItemModel(userId: userId,
                                     isSender: true,
                                     content: "写一份关于太空旅行的市场分析报告",
                                     msgState: .success,
                                     timestamp: Date()),

                    MessageItemModel(userId: userId,
                                     isSender: false,
                                     content:
                                     """
                                         近年来,随着商业航天公司的崛起和旅游业的发展,太空旅行市场势头正猛。本报告从市场规模、主要参与者、消费者需求、法律监管等多个角度分析了太空旅行市场的发展现状及未来趋势。

                                         根据预测,到2030年,太空旅行市场规模将达到100亿美元。目前SpaceX、Blue Origin及Virgin Galactic是行业的主要参与者,正在开发可重复使用的次轨道太空载具。随着载人航天飞机的运营成本不断下降,预计每年将有数万游客前往太空旅行。
                                     """,
                                     msgState: .success,
                                     timestamp: Date())
                ]
            },
            loadInputTips: {
                [
                    "历史",
                    "诗歌",
                    "散文"
                ]
            }
        )
    }

    static var testValue: MessageAPIClient = Self(
        requestHomeProfile: unimplemented("\(Self.self).requestHomeProfile"),
        loadHistoryTopic: unimplemented("\(Self.self).loadHistoryTopic"),
        loadMsgList: unimplemented("\(Self.self).loadMsgList"),
        loadInputTips: unimplemented("\(Self.self).loadInputTips")
    )
}

extension DependencyValues {
    var messageAPIClient: MessageAPIClient {
        get { self[MessageAPIClient.self] }
        set { self[MessageAPIClient.self] = newValue }
    }
}
