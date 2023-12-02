//
//  MemberHeaderItemModel.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/2.
//

import Foundation

struct MemberHeaderItemModel: RawRepresentable, Codable, Equatable, Hashable, Identifiable {
    var id: String {
        rawValue
    }
    let rawValue: String
    static let gtp3 = MemberHeaderItemModel(rawValue: "无限聊天GPT3.5")
    static let gtp4 = MemberHeaderItemModel(rawValue: "解锁ChatGPT4.0")
    static let assistant = MemberHeaderItemModel(rawValue: "解锁所有AI助手")
    static let server = MemberHeaderItemModel(rawValue: "专用服务器快速")
    static let ads = MemberHeaderItemModel(rawValue: "删除所有广告")
    static let update = MemberHeaderItemModel(rawValue: "持续更新")
    
    var imageName: String {
        switch self {
        case .gtp3:
            return "member_icon_chat"
        case .gtp4:
            return "member_icon_unlock"
        case .assistant:
            return "member_icon_brain"
        case .server:
            return "member_icon_earth"
        case .ads:
            return "member_icon_ad"
        default:
            return "member_icon_brainline"
        }
    }
}
