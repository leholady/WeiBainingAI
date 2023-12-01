//
//  MoreOptionsGroupModel.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/1.
//

import Foundation

struct MoreOptionsGroupModel: RawRepresentable, Codable, Equatable, Hashable, Identifiable {
    var id: String {
        rawValue
    }
    let rawValue: String
    static let groupBalance = MoreOptionsGroupModel(rawValue: "平衡")
    static let groupMember = MoreOptionsGroupModel(rawValue: "会员")
    static let groupHistory = MoreOptionsGroupModel(rawValue: "历史")
    static let groupAbout = MoreOptionsGroupModel(rawValue: "关于")
    
    var items: [MoreOptionsItemModel] {
        switch self {
        case .groupMember:
            return [.itemMember, .itemResume]
        case .groupHistory:
            return [.itemChat]
        case .groupAbout:
            return [.itemShare, .itemConnect, .itemPolicy, .itemAgreement]
        default:
            return [.itemBalance]
        }
    }
 
    struct MoreOptionsItemModel: RawRepresentable, Codable, Equatable, Hashable, Identifiable {
        var id: String {
            rawValue
        }
        let rawValue: String
        static let itemBalance = MoreOptionsItemModel(rawValue: "balance")
        static let itemMember = MoreOptionsItemModel(rawValue: "升级为Premium")
        static let itemResume = MoreOptionsItemModel(rawValue: "恢复购买")
        static let itemChat = MoreOptionsItemModel(rawValue: "聊天话题")
        static let itemShare = MoreOptionsItemModel(rawValue: "分享App")
        static let itemConnect = MoreOptionsItemModel(rawValue: "联系我们")
        static let itemPolicy = MoreOptionsItemModel(rawValue: "隐私政策")
        static let itemAgreement = MoreOptionsItemModel(rawValue: "用户协议")
        
        var imageName: String {
            switch self {
            case .itemMember:
                return "more_icon_premium"
            case .itemResume:
                return "more_icon_repurchase"
            case .itemChat:
                return "more_icon_history"
            case .itemShare:
                return "more_icon_share"
            case .itemConnect:
                return "more_icon_mail"
            case .itemPolicy:
                return "more_icon_lock"
            case .itemAgreement:
                return "more_icon_terms"
            default:
                return ""
            }
        }
    }
}
