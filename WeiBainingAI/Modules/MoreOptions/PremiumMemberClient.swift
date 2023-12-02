//
//  PremiumMemberClient.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/2.
//

import ComposableArchitecture
import Foundation

struct PremiumMemberClient {
    var premiumMemberPageItems: @Sendable () async throws -> [PremiumMemberPageModel]
}

extension PremiumMemberClient: TestDependencyKey {
    static var previewValue: PremiumMemberClient {
        Self {
            [PremiumMemberPageModel(pageState: .premium,
                                    pageItems: [PremiumMemberModel(productId: UUID().uuidString, title: ""),
                                                PremiumMemberModel(productId: UUID().uuidString, title: ""),
                                                PremiumMemberModel(productId: UUID().uuidString, title: "")]),
             PremiumMemberPageModel(pageState: .premium,
                                     pageItems: [PremiumMemberModel(productId: UUID().uuidString, title: ""),
                                                 PremiumMemberModel(productId: UUID().uuidString, title: "")])]
        }
    }
}

extension PremiumMemberClient: DependencyKey {
    static var liveValue: PremiumMemberClient {
        Self {
            throw Unimplemented("moreBalanceItems not implemented")
        }
    }
}
