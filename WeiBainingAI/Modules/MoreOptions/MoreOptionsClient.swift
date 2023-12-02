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
            [MoreBalanceItemModel(title: "ChatGPT 3.5",
                                  number: "Unlimited",
                                  unit: ""),
             MoreBalanceItemModel(title: "ChatGPT 4.0",
                                  number: "10.1w",
                                  unit: "Tokens"),
             MoreBalanceItemModel(title: "Midjourney",
                                  number: "65",
                                  unit: "Images")]
        }
    }
}

extension MoreOptionsClient: DependencyKey {
    static var liveValue: MoreOptionsClient {
        Self {
            throw Unimplemented("moreBalanceItems not implemented")
        }
    }
}
