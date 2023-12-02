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

/// 聊天模型
struct ChatModelConfig: Equatable, Codable, Identifiable, Hashable {
    var id: Int
    var title: String
    var desc: String
}

/// 聊天配置
struct ChatRequestConfigMacro: Equatable, Codable {
    var temperature: Double
    var model: ChatModelConfig
    var maxtokens: Int
    var msgCount: Int
    var conversationId: Int?

    static func defaultConfig() -> ChatRequestConfigMacro {
        return ChatRequestConfigMacro(temperature: 1,
                                      model: ChatModelConfig(id: 1, title: "GPT-3.5 Turbo", desc: "Turbo 针对对话进行了优化"),
                                      maxtokens: 64,
                                      msgCount: 1,
                                      conversationId: nil)
    }
}
