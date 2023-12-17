//
//  PremiumMemberPageModel.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/2.
//

import Foundation

struct PremiumMemberPageModel: Codable, Equatable, Hashable, Identifiable {
    var id: String {
        pageState.title
    }
    var pageState: PremiumMemberPageState
    var pageItems: [PremiumMemberModel]
    
    struct PremiumMemberPageState: Codable, RawRepresentable, Equatable, Hashable {
        var id: String {
            title
        }
        var title: String {
            switch self {
            case .premium:
                return "Premium"
            case .quota:
                return "Quota"
            default:
                return "Premium"
            }
        }
        var headerTitle: String {
            switch self {
            case .premium:
                return "Premium会员"
            case .quota:
                return "Chat Quota"
            default:
                return "Premium"
            }
        }
        let rawValue: Int
        static let premium = PremiumMemberPageState(rawValue: 0)
        static let quota = PremiumMemberPageState(rawValue: 1)
    }
}
