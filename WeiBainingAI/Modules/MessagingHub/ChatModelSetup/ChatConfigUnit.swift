//
//  ChatConfigUnit.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/1.
//

import UIKit

enum ChatStyleType: Int, Equatable, Hashable {
    case creativity = 1
    case balance = 2
    case accurate = 3

    var title: String {
        switch self {
        case .creativity:
            return "创造力"
        case .balance:
            return "平衡"
        case .accurate:
            return "精确"
        }
    }
}

enum ChatModelType: Int, Codable, Equatable, Hashable {
    case gpt3_5 = 1
    case gpt4 = 2

    var title: String {
        switch self {
        case .gpt3_5:
            return "GPT-3.5 Turbo"
        case .gpt4:
            return "GPT-4"
        }
    }

    var desc: String {
        switch self {
        case .gpt3_5:
            return "Turbo 针对对话进行了优化"
        case .gpt4:
            return "GPT-4可以遵循复杂的指令并准确地解决难题。"
        }
    }

    var code: String {
        switch self {
        case .gpt3_5:
            return "gpt-3.5"
        case .gpt4:
            return "gpt-4"
        }
    }
}

/// 聊天模型
struct ChatModelConfig: Equatable, Codable, Identifiable, Hashable {
    var id: Int
    var title: String
    var desc: String
}

/// 聊天配置
struct ChatRequestConfigMacro: Equatable, Codable {
    var temperature: Double
    var model: ChatModelType
    var maxtokens: Int
    var msgCount: Int
    var conversationId: Int
    var userId: String

    static func defaultConfig() -> ChatRequestConfigMacro {
        return ChatRequestConfigMacro(temperature: 1,
                                      model: .gpt3_5,
                                      maxtokens: 2000,
                                      msgCount: 1,
                                      conversationId: 1,
                                      userId: "")
    }
}
