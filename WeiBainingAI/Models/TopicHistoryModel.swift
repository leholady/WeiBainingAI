//
//  TopicHistoryModel.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/28.
//

import UIKit

struct TopicHistoryModel: Codable, Equatable, Hashable, Identifiable {
    let id: String
    var timestamp: Date
    var topic: String
    var reply: String

    init(id: String = UUID().uuidString, timestamp: Date, topic: String, reply: String) {
        self.id = id
        self.timestamp = timestamp
        self.topic = topic
        self.reply = reply
    }
}

struct MessageItemModel: Codable, Equatable, Hashable, Identifiable {
    let id: String
    var userId: Int
    var isSender: Bool
    var content: String
    var msgState: MessageState // 0、发送中， 1、成功， 2、失败
    var timestamp: Date

    enum MessageState: Int, Codable {
        case sending = 0
        case generating = 1
        case success = 2
        case failed = 3
    }

    init(id: String = UUID().uuidString, userId: Int, isSender: Bool, content: String, msgState: MessageState, timestamp: Date) {
        self.id = id
        self.userId = userId
        self.isSender = isSender
        self.content = content
        self.msgState = msgState
        self.timestamp = timestamp
    }
}
