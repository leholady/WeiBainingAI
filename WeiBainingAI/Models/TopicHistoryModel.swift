//
//  TopicHistoryModel.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/28.
//

import UIKit
import WCDBSwift

struct MessageDialogModel: Codable, Equatable {
    var content: String
    var role: MessageSendRole
}

enum MessageSendRole: String, Codable {
    case user = "user"
    case robot = "assistant"
}

enum MessageSendState: Int, Codable {
    case sending = 0
    case generating = 1
    case success = 2
    case failed = 3
}

// MARK: - WCDB

struct ConversationItemWCDB: TableCodable, Equatable, Hashable, Identifiable {
    var id: Int {
        return identifier
    }

    var identifier: Int
    var userId: String
    var timestamp: Date
    var topic: String
    var reply: String

    var isAutoIncrement: Bool { return true }
    var lastInsertedRowID: Int64 = 0 // 用于获取自增插入后的主键值
    var isSelected: Bool = false // 用于标记选中状态

    /// 用于 WCDBSwift 的表名
    enum CodingKeys: String, CodingTableKey {
        typealias Root = ConversationItemWCDB
        case identifier
        case userId
        case timestamp
        case topic
        case reply

        static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(identifier, isPrimary: true, isAutoIncrement: true)
        }
    }

    init(_ identifier: Int = 0, userId: String, timestamp: Date, topic: String, reply: String) {
        self.identifier = identifier
        self.userId = userId
        self.timestamp = timestamp
        self.topic = topic
        self.reply = reply
    }

    static var tableName: String {
        return "ConversationItemTable"
    }
}

struct MessageItemWCDB: TableCodable, Equatable, Hashable, Identifiable {
    var id: Int {
        identifier
    }
    var identifier: Int
    var conversationId: Int
    var role: String // user, assistant
    var content: String
    var msgState: Int // 0、发送中， 1、成功， 2、失败
    var timestamp: Date

    var roleType: MessageSendRole {
        MessageSendRole(rawValue: role) ?? .user
    }

    var msgStateType: MessageSendState {
        MessageSendState(rawValue: msgState) ?? .sending
    }

    var isAutoIncrement: Bool { return true }
    static var tableName: String {
        return "MessageItemTable"
    }

    enum CodingKeys: String, CodingTableKey {
        typealias Root = MessageItemWCDB
        case identifier
        case conversationId
        case role
        case content
        case msgState
        case timestamp
        static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(identifier, isPrimary: true, isAutoIncrement: true)
        }
    }

    init(_ identifier: Int = 0, conversationId: Int, role: String, content: String, msgState: Int, timestamp: Date) {
        self.identifier = identifier
        self.conversationId = conversationId
        self.role = role
        self.content = content
        self.msgState = msgState
        self.timestamp = timestamp
    }
}
