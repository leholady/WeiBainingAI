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
struct ChatModelItemMacro: Equatable, Codable, Identifiable, Hashable {
    var id: Int
    var title: String
    var desc: String
}
