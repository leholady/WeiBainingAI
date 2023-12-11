//
//  MessageActor.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/7.
//

import Logging
import Speech
import UIKit
import WCDB

// MARK: - 处理语音识别actor

actor SpeechEngineActor {
    var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var audioEngine: AVAudioEngine?
    var recognitionTask: SFSpeechRecognitionTask?

    func startVoiceToText() -> AsyncThrowingStream<String, Error> {
        audioEngine = AVAudioEngine()
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        // 建立一个AVAudioSession 用于录音
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            debugPrint("audioSession properties weren't set because of an error.")
            return AsyncThrowingStream<String, Error> { continuation in
                continuation.finish(throwing: error)
            }
        }
        // 初始化RecognitionRequest，在后边我们会用它将录音数据转发给苹果服务器
        let inputNode = audioEngine?.inputNode
        // 在用户说话的同时，将识别结果分批次返回
        recognitionRequest?.shouldReportPartialResults = true
        if let recognitionRequest = recognitionRequest {
            return AsyncThrowingStream<String, Error> { continuation in
                // ... 建立AVAudioSession和其余的识别请求代码 ...
                recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { result, error in
                    if let error = error {
                        self.stopVoiceRecognition()
                        continuation.finish(throwing: error)
                    }
                    if result?.isFinal == true {
                        self.stopVoiceRecognition()
                        continuation.finish()
                    }
                    continuation.yield(result?.bestTranscription.formattedString ?? "")
                })

                // 向recognitionRequest加入一个音频输入
                let recordingFormat = inputNode?.outputFormat(forBus: 0)
                inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                    self.recognitionRequest?.append(buffer)
                }
                audioEngine?.prepare()
                do {
                    // 开始录音
                    try audioEngine?.start()
                } catch {
                    debugPrint("audioEngine couldn't start because of an error.")
                    continuation.finish(throwing: error)
                }
            }
        } else {
            return AsyncThrowingStream<String, Error> { continuation in
                continuation.finish(throwing: NSError(domain: "SpeechEngineActor", code: 0, userInfo: nil))
            }
        }
    }

    // 这是一个新的方法，用于停止语音识别。
    func stopVoiceRecognition() {
        recognitionTask?.cancel()
        recognitionTask = nil
        if let inputNode = audioEngine?.inputNode {
            inputNode.removeTap(onBus: 0)
        }
        audioEngine?.stop()
        audioEngine = nil
        recognitionRequest = nil
    }
}

// MARK: - 处理数据库actor

actor MessageDbActor {
    static let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let database = Database(at: "\(MessageDbActor.documentsPath)/WeiBainingAI.db")

    /// 创建表
    func createTable() async throws {
        try database.create(table: ConversationItemDb.tableName, of: ConversationItemDb.self)
        try database.create(table: MessageItemDb.tableName, of: MessageItemDb.self)
    }

    /// 插入会话
    func insertConversationItem(_ userId: String) async throws -> ConversationItemDb {
        var topic = ConversationItemDb(userId: userId, timestamp: Date(), topic: "", reply: "")
        try database.insert(topic, intoTable: ConversationItemDb.tableName)
        Logger(label: "createConversation").info("create conversation: \(topic.lastInsertedRowID)")
        // 获取 identifier 的最大值
        let maxIdentifier = try database.getValue(on: ConversationItemDb.Properties.identifier.max(),
                                                  fromTable: ConversationItemDb.tableName)
        topic.identifier = Int(maxIdentifier.int64Value)
        return topic
    }

    /// 更新会话
    func updateConversationItem(_ conversation: ConversationItemDb,
                                _ msg: MessageItemDb) async throws {
        var conversation = conversation
        if msg.role == MessageSendRole.robot.rawValue {
            conversation.reply = msg.content
            conversation.timestamp = msg.timestamp
            try database.update(table: ConversationItemDb.tableName,
                                on: [ConversationItemDb.Properties.reply,
                                     ConversationItemDb.Properties.timestamp],
                                with: conversation,
                                where: ConversationItemDb.Properties.identifier == conversation.identifier)
        } else {
            conversation.topic = msg.content
            try database.update(table: ConversationItemDb.tableName,
                                on: ConversationItemDb.Properties.topic,
                                with: conversation,
                                where: ConversationItemDb.Properties.identifier == conversation.identifier)
        }
    }

    /// 删除会话
    func deleteConversationItem(_ conversations: [ConversationItemDb]) async throws {
        try conversations.forEach { conversation in
            try database.delete(fromTable: ConversationItemDb.tableName,
                                where: ConversationItemDb.Properties.identifier == conversation.identifier)
        }
    }

    /// 获取会话列表
    func getConversationItem(_ userId: String) async throws -> [ConversationItemDb] {
        return try database.getObjects(
            on: ConversationItemDb.Properties.all,
            fromTable: ConversationItemDb.tableName,
            where: ConversationItemDb.Properties.userId == userId
        )
    }

    /// 插入消息
    func insertMessageItem(_ msg: MessageItemDb) async throws {
        return try database.insert([msg], intoTable: MessageItemDb.tableName)
    }

    /// 获取消息列表
    func getMessageItem(_ conversationId: Int) async throws -> [MessageItemDb] {
        return try database.getObjects(
            on: MessageItemDb.Properties.all,
            fromTable: MessageItemDb.tableName,
            where: MessageItemDb.Properties.conversationId == conversationId
        )
    }

    /// 删除消息
    func deleteMessageItem(_ msg: MessageItemDb, _ msgList: [MessageItemDb]) async throws -> [MessageItemDb] {
        try database.delete(fromTable: MessageItemDb.tableName,
                            where: MessageItemDb.Properties.identifier == msg.identifier)
        return msgList.filter { $0.identifier != msg.identifier }
//        // 根据传入的消息，以消息组上下文方式，查询队组
//        let currentIndex = msgList.firstIndex(where: { $0.identifier == msg.identifier }) ?? 0
//        // 检查上一条消息和下一条消息是否存在，以及它们的内容
//        if msg.roleType == .user {
//            if currentIndex < msgList.count - 1 {
//                let nextMsg = msgList[currentIndex + 1]
//                try database.delete(fromTable: MessageItemDb.tableName,
//                                    where: MessageItemDb.Properties.identifier == msg.identifier)
//                try database.delete(fromTable: MessageItemDb.tableName,
//                                    where: MessageItemDb.Properties.identifier == nextMsg.identifier)
//            }
//        } else {
//            if currentIndex > 0 {
//                let previousMsg = msgList[currentIndex - 1]
//                try database.delete(fromTable: MessageItemDb.tableName,
//                                    where: MessageItemDb.Properties.identifier == msg.identifier)
//                try database.delete(fromTable: MessageItemDb.tableName,
//                                    where: MessageItemDb.Properties.identifier == previousMsg.identifier)
//            }
//        }
    }
}
