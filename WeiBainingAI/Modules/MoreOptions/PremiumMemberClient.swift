//
//  PremiumMemberClient.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/2.
//

import ComposableArchitecture
import Foundation
import StoreKit

struct PremiumMemberClient {
    /// 获取支付所有配置列表
    var payConfList: @Sendable () async throws -> [PremiumMemberPageModel]
}

extension PremiumMemberClient: DependencyKey {
    static var liveValue: PremiumMemberClient {
        let handler = HttpRequestHandler()
        return Self(
            payConfList: {
                var models = try await handler.payConfList()
                let products = try await Product.products(for: Set(models.map { $0.productId }))
                models = models.compactMap { item in
                    guard let product = products.first(where: { $0.id == item.productId }) else {
                        return nil
                    }
                    return item.newModelTo(product)
                }
                var pages: [PremiumMemberPageModel] = []
                for model in models {
                    switch model.state {
                    case .quota:
                        if let index = pages.firstIndex(where: { $0.pageState == .quota }) {
                            pages[index].pageItems.append(model)
                        } else {
                            pages.append(PremiumMemberPageModel(pageState: .quota, pageItems: [model]))
                        }
                    case .premium:
                        if let index = pages.firstIndex(where: { $0.pageState == .premium }) {
                            pages[index].pageItems.append(model)
                        } else {
                            pages.append(PremiumMemberPageModel(pageState: .premium, pageItems: [model]))
                        }
                    default:
                        break
                    }
                }
                return pages
            }
        )
    }
}
