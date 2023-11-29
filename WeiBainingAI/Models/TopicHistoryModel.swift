//
//  TopicHistoryModel.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/28.
//

import UIKit

struct TopicHistoryModel: Codable, Equatable, Hashable, Identifiable {
    var id: String {
        UUID().uuidString
    }

    var timestamp: Date
    var topic: String
    var reply: String

    var timeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: timestamp)
    }
}

struct MessageItemModel: Codable, Equatable, Hashable, Identifiable {
    var id: String {
        UUID().uuidString
    }

    var userId: Int
    var isSender: Bool
    var content: String
    var msgState: MessageState // 0、发送中， 1、成功， 2、失败
    var timestamp: Date
    var timeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: timestamp)
    }

    enum MessageState: Int, Codable {
        case sending = 0
        case generating = 1
        case success = 2
        case failed = 3
    }
}
