//
//  PremiumMemberPageModel.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/2.
//

import Foundation

struct PremiumMemberPageModel: Codable, Equatable, Hashable, Identifiable {
    var id: String {
        pageState.rawValue
    }
    var pageState: PremiumMemberPageState
    var pageItems: [PremiumMemberModel]
    
    struct PremiumMemberPageState: Codable, RawRepresentable, Equatable, Hashable {
        var id: String {
            rawValue
        }
        let rawValue: String
        static let premium = PremiumMemberPageState(rawValue: "Premium")
        static let quota = PremiumMemberPageState(rawValue: "Quota")
    }
}
