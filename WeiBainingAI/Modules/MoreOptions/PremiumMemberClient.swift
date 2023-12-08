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
    var updates: @Sendable () async -> Transaction.Transactions
    var payConfList: @Sendable () async throws -> [PremiumMemberModel]
    var memberProducts: @Sendable ([String]) async throws -> [Product]
    var memberPageModels: @Sendable ([PremiumMemberModel], [Product]) async throws -> [PremiumMemberPageModel]
    var memberPurchase: @Sendable (Product) async throws -> Transaction
    var verification: @Sendable (VerificationResult<Transaction>) throws -> Transaction
    var payAppStore: @Sendable (String, String) async throws -> Bool
    var payApple: @Sendable (String) async throws -> Bool
    var recover: @Sendable () async throws -> Transaction.Transactions
}

extension PremiumMemberClient: DependencyKey {
    static var liveValue: PremiumMemberClient {
        let handler = HttpRequestHandler()
        return Self(
            updates: {
                Transaction.updates
            },
            payConfList: {
                try await handler.payConfList()
            },
            memberProducts: {
                try await Product.products(for: Set($0))
            },
            memberPageModels: {
                var models = $0
                let products = $1
                models = models.compactMap { item in
                    guard let product = products.first(where: { $0.id == item.productId }) else {
                        return nil
                    }
                    return item.newModelTo(product)
                }
                var pages: [PremiumMemberPageModel] = []
                for model in models {
                    guard let state = model.state else {
                        continue
                    }
                    switch state {
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
            },
            memberPurchase: {
                let result = try await $0.purchase()
                switch result {
                case .success(let verification):
                    switch verification {
                    case .unverified:
                        throw StoreError.validationFailed
                    case .verified(let signed):
                        return signed
                    }
                case .userCancelled:
                    throw StoreError.canceled
                case .pending:
                    throw StoreError.determined
                default:
                    throw StoreError.unowned
                }
            },
            verification: {
                switch $0 {
                case .unverified:
                    throw StoreError.validationFailed
                case .verified(let signed):
                    return signed
                }
            },
            payAppStore: {
                return try await handler.payAppStoreV2($0, originalTransactionId: $1)
            },
            payApple: {
                return try await handler.payAppleV2($0)
            },
            recover: {
                try await AppStore.sync()
                return Transaction.unfinished
            }
        )
    }
}

extension DependencyValues {
    var memberClient: PremiumMemberClient {
        get { self[PremiumMemberClient.self] }
        set { self[PremiumMemberClient.self] = newValue }
    }
}

enum StoreError: Error {
    case unowned
    case canceled
    case determined
    case validationFailed
}
