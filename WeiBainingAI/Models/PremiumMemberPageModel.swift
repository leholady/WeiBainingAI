//
//  PremiumMemberPageModel.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/2.
//

import Foundation

enum PremiumMemberPageState: String, Equatable, Hashable, Identifiable {
    var id: String {
        rawValue
    }
    case premium = "Premium"
    case quota = "Quota"
}

struct PremiumMemberPageModel: Equatable, Hashable, Identifiable {
    var id: String {
        pageState.rawValue
    }
    var pageState: PremiumMemberPageState
    var pageItems: [PremiumMemberModel]
}
