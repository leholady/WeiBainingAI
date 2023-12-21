//
//  MoreOptionsClient.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/1.
//

import ComposableArchitecture

struct MoreOptionsClient {
    var moreBalanceItems: @Sendable () async throws -> [MoreBalanceItemModel]
}

extension MoreOptionsClient: TestDependencyKey {
    static var previewValue: MoreOptionsClient {
        Self {
            [MoreBalanceItemModel(title: "Chat 3.5",
                                  number: "Unlimited",
                                  unit: ""),
             MoreBalanceItemModel(title: "Chat 4.0",
                                  number: "10.1w",
                                  unit: "Tokens")]
        }
    }
}

extension MoreOptionsClient: DependencyKey {
    static var liveValue: MoreOptionsClient {
        let handler = HttpRequestHandler()
        return Self(
            moreBalanceItems: {
                let integral = try await handler.getByOwner()
               return [MoreBalanceItemModel(title: "Chat 3.5",
                                      number: "Unlimited",
                                      unit: ""),
                 MoreBalanceItemModel(title: "Chat 4.0",
                                      number: "\(integral)",
                                      unit: "Tokens")]
            }
        )
    }
}
