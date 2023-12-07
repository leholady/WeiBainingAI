//
//  MessageDbClient.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/3.
//

import Dependencies
import Logging
import UIKit
import WCDBSwift

struct MessageDbClient {
    /// 初始化数据库
    var initDatabase: @Sendable () async throws -> Bool
    /// 加载聊天会话
    var createConversation: @Sendable (_ userId: String) async throws -> ConversationItemDb
    /// 更新聊天会话
    var updateConversation: @Sendable (_ conversation: ConversationItemDb,
                                       _ msg: MessageItemDb) async throws -> Void
    /// 从数据库加载历史会话话题
    var loadConversation: @Sendable (_ userId: String) async throws -> [ConversationItemDb]
    /// 从数据库加载历史消息
    var loadMessages: @Sendable (_ conversation: ConversationItemDb) async throws -> [MessageItemDb]
    /// 保存单项消息到数据库
    var saveSingleMessage: @Sendable (_ msg: MessageItemDb) async throws -> Void
    /// 传入会话数据，删除会话
    var deleteConversation: @Sendable (_ conversations: [ConversationItemDb]) async throws -> Void
    /// 传入当前点击的消息模型，删除对应的消息
    var deleteMessageGroup: @Sendable (_ msg: MessageItemDb, _ msgList: [MessageItemDb]) async throws -> Void
}

extension MessageDbClient: DependencyKey {
    static var liveValue: MessageDbClient {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let database = Database(at: "\(documentsPath)/WeiBainingAI.db")

        return Self {
            try database.create(table: ConversationItemDb.tableName, of: ConversationItemDb.self)
            try database.create(table: MessageItemDb.tableName, of: MessageItemDb.self)
            return true
        } createConversation: {
            var topic = ConversationItemDb(userId: $0, timestamp: Date(), topic: "", reply: "")
            try database.insert(topic, intoTable: ConversationItemDb.tableName)
            Logger(label: "createConversation").info("create conversation: \(topic.lastInsertedRowID)")
            // 获取 identifier 的最大值
            let maxIdentifier = try database.getValue(on: ConversationItemDb.Properties.identifier.max(),
                                                      fromTable: ConversationItemDb.tableName)
            topic.identifier = Int(maxIdentifier.int64Value)
            return topic
        } updateConversation: {
            var conversation = $0
            if $1.role == MessageSendRole.robot.rawValue {
                conversation.reply = $1.content
                conversation.timestamp = $1.timestamp
                try database.update(table: ConversationItemDb.tableName,
                                    on: [ConversationItemDb.Properties.reply,
                                         ConversationItemDb.Properties.timestamp],
                                    with: conversation,
                                    where: ConversationItemDb.Properties.identifier == $0.identifier)
            } else {
                conversation.topic = $1.content
                try database.update(table: ConversationItemDb.tableName,
                                    on: ConversationItemDb.Properties.topic,
                                    with: conversation,
                                    where: ConversationItemDb.Properties.identifier == $0.identifier)
            }

        } loadConversation: {
            let topics: [ConversationItemDb] = try database.getObjects(
                on: ConversationItemDb.Properties.all,
                fromTable: ConversationItemDb.tableName,
                where: ConversationItemDb.Properties.userId == $0
            )
            return topics
        } loadMessages: {
            let messages: [MessageItemDb] = try database.getObjects(
                on: MessageItemDb.Properties.all,
                fromTable: MessageItemDb.tableName,
                where: MessageItemDb.Properties.conversationId == $0.identifier
            )
            return messages
        } saveSingleMessage: {
            try database.insert([$0], intoTable: MessageItemDb.tableName)
        } deleteConversation: {
            try $0.forEach { conversation in
                try database.delete(fromTable: ConversationItemDb.tableName,
                                    where: ConversationItemDb.Properties.identifier == conversation.identifier)
            }
        } deleteMessageGroup: { msg, msgList in
            // 根据传入的消息，以消息组上下文方式，查询队组
            let currentIndex = msgList.firstIndex(where: { $0.identifier == msg.identifier }) ?? 0
            // 检查上一条消息和下一条消息是否存在，以及它们的内容
            if msg.roleType == .user {
                if currentIndex < msgList.count - 1 {
                    let nextMsg = msgList[currentIndex + 1]
                    try database.delete(fromTable: MessageItemDb.tableName,
                                        where: MessageItemDb.Properties.identifier == msg.identifier)
                    try database.delete(fromTable: MessageItemDb.tableName,
                                        where: MessageItemDb.Properties.identifier == nextMsg.identifier)
                }
            } else {
                if currentIndex > 0 {
                    let previousMsg = msgList[currentIndex - 1]
                    try database.delete(fromTable: MessageItemDb.tableName,
                                        where: MessageItemDb.Properties.identifier == msg.identifier)
                    try database.delete(fromTable: MessageItemDb.tableName,
                                        where: MessageItemDb.Properties.identifier == previousMsg.identifier)
                }
            }
        }
    }
}

extension MessageDbClient: TestDependencyKey {
    static var previewValue: MessageDbClient {
        return Self(
            initDatabase: {
                true
            },
            createConversation: { _ in
                ConversationItemDb(userId: "", timestamp: Date(), topic: "", reply: "")
            }, updateConversation: { _, _ in

            },
            loadConversation: { _ in
                [
                    ConversationItemDb(userId: "", timestamp: Date(),
                                       topic: "写一篇关于二手车买卖市场趋势的调查报告",
                                       reply: "请求错误，请重试"),
                    ConversationItemDb(userId: "", timestamp: Date(),
                                       topic: "写一篇关于二手车买卖市场趋势的调查报告",
                                       reply: "根据最近几年的统计数据分析,国内二手车交易市场持续活跃,交易量稳步上升。报告预测未来5年二手车交易额还将保持较快增长态势。主要原因在于..."),

                    ConversationItemDb(userId: "", timestamp: Date(),
                                       topic: "写一首反映工业文明的现代叙事诗",
                                       reply: "铁与铜构成 agora 的框架,玻璃反射着太阳的光辉。烟囱向天空喷泄着,工人们操作着,机器轰鸣作响..."),

                    ConversationItemDb(userId: "", timestamp: Date(),
                                       topic: "给喜欢登山的朋友写一封生日贺卡",
                                       reply: "每当看到高山,总会想起你激动而专注的神情。每一座峰顶都是你的生日礼物,愿你像攀登山峰那样勇往直前,从未放弃梦想!")
                ]
            },
            loadMessages: { topic in
                [
                    MessageItemDb(conversationId: topic.identifier,
                                  role: MessageSendRole.user.rawValue,
                                  content: "写一首古代散文诗歌",
                                  msgState: MessageSendState.success.rawValue,
                                  timestamp: Date()),
                    MessageItemDb(conversationId: topic.identifier,
                                  role: MessageSendRole.robot.rawValue,
                                  content: "请求错误，请重试",
                                  msgState: MessageSendState.success.rawValue,
                                  timestamp: Date()),

                    MessageItemDb(conversationId: topic.identifier,
                                  role: MessageSendRole.user.rawValue,
                                  content: "写一首古代散文诗歌",
                                  msgState: MessageSendState.success.rawValue,
                                  timestamp: Date()),
                    MessageItemDb(conversationId: topic.identifier,
                                  role: MessageSendRole.robot.rawValue,
                                  content: "在昔日的土地上，影子舞动，时间展开古老的恍惚，一个故事展开，很久以前的日子，低声吟唱，将永远持续。在月亮的空灵光芒下，古老的智慧，赋予的秘密，星星的交响曲 点燃黑夜，引导灵魂穿越古老力量的国度。",
                                  msgState: MessageSendState.success.rawValue,
                                  timestamp: Date()),

                    MessageItemDb(conversationId: topic.identifier,
                                  role: MessageSendRole.user.rawValue,
                                  content: "写一份关于太空旅行的市场分析报告",
                                  msgState: MessageSendState.success.rawValue,
                                  timestamp: Date()),

                    MessageItemDb(conversationId: topic.identifier,
                                  role: MessageSendRole.robot.rawValue,
                                  content:
                                  """
                                      近年来,随着商业航天公司的崛起和旅游业的发展,太空旅行市场势头正猛。本报告从市场规模、主要参与者、消费者需求、法律监管等多个角度分析了太空旅行市场的发展现状及未来趋势。

                                      根据预测,到2030年,太空旅行市场规模将达到100亿美元。目前SpaceX、Blue Origin及Virgin Galactic是行业的主要参与者,正在开发可重复使用的次轨道太空载具。随着载人航天飞机的运营成本不断下降,预计每年将有数万游客前往太空旅行。
                                  """,
                                  msgState: MessageSendState.success.rawValue,
                                  timestamp: Date())
                ]
            },
            saveSingleMessage: { _ in },
            deleteConversation: { _ in },
            deleteMessageGroup: { _, _ in }
        )
    }

    static var testValue: MessageDbClient {
        Self(
            initDatabase: unimplemented("\(Self.self).initDatabase"),
            createConversation: unimplemented("\(Self.self).createConversation"),
            updateConversation: unimplemented("\(Self.self).updateConversation"),
            loadConversation: unimplemented("\(Self.self).loadConversation"),
            loadMessages: unimplemented("\(Self.self).loadMessages"),
            saveSingleMessage: unimplemented("\(Self.self).saveSingleMessage"),
            deleteConversation: unimplemented("\(Self.self).deleteConversation"),
            deleteMessageGroup: unimplemented("\(Self.self).deleteMessageGroup")
        )
    }
}

extension DependencyValues {
    var dbClient: MessageDbClient {
        get { self[MessageDbClient.self] }
        set { self[MessageDbClient.self] = newValue }
    }
}
