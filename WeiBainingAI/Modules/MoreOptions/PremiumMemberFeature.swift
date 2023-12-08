//
//  PremiumMemberFeature.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/2.
//

import Foundation
import ComposableArchitecture
import StoreKit
import SVProgressHUD
import Logging

@Reducer
struct PremiumMemberFeature {
    
    struct State: Equatable {
        var headerItems: [MemberHeaderItemModel] = [.gtp3, .gtp4, .assistant, .server, .ads, .update]
        var products: [Product] = []
        @BindingState var pageSelect: Int = 0
        var pageItems: [PremiumMemberPageModel] = []
        @PresentationState var safariState: MoreSafariFeature.State?
        @BindingState var itemSelects: [Int]?
    }
    
    enum Action: BindableAction, Equatable {
        case premiumDismiss
        case uploadProducts
        case productsUpdate(TaskResult<[Product]>)
        case uploadPageItems
        case pageItemsUpdate(TaskResult<[PremiumMemberPageModel]>)
        case binding(BindingAction<State>)
        case dismissSafari(URL)
        case fullScreenCoverSafari(PresentationAction<MoreSafariFeature.Action>)
        case cellDidAt(Int, Int)
        case memberStartBuy
        case startBuy(Product)
        case uploadUserProfile
        case recover
        case recoverValidation(TaskResult<Transaction>)
        case recoverResponse(TaskResult<PremiumValidationResponse>)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.memberClient) var memberClient
    @Dependency(\.httpClient) var httpClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .premiumDismiss:
                return .run { _ in
                    await self.dismiss()
                }
            case let .productsUpdate(.success(products)):
                state.products = products
                return .none
            case .uploadPageItems:
                return .run { send in
                    let items = try await memberClient.payConfList()
                    let products = try await memberClient.memberProducts(items.map { $0.productId })
                    await send(.productsUpdate(TaskResult { products }))
                    await send(.pageItemsUpdate(
                        TaskResult {
                            try await memberClient.memberPageModels(items, products)
                        }
                    ))
                }
            case let .pageItemsUpdate(.success(items)):
                state.pageItems = items
                state.itemSelects = items.compactMap { _ in 0 }
                return .none
            case let .dismissSafari(url):
                state.safariState = MoreSafariFeature.State(url: url)
                return .none
            case let .cellDidAt(pageIndex, itemIndex):
                state.itemSelects?[pageIndex] = itemIndex
                return .none
            case .memberStartBuy:
                guard state.pageSelect < state.pageItems.count,
                      let itemSelects = state.itemSelects,
                      state.pageSelect < itemSelects.count,
                      itemSelects[state.pageSelect] < state.pageItems[state.pageSelect].pageItems.count,
                      let product = state.products.first(where: { $0.id == state.pageItems[state.pageSelect].pageItems[itemSelects[state.pageSelect]].productId }) else {
                    SVProgressHUD.showError(withStatus: "当前商品不可用, 请选择其他商品")
                    return .none
                }
                return .run { send in
                    await send(.startBuy(product))
                }
            case let .startBuy(product):
                return .run { send in
                    do {
                        await SVProgressHUD.show()
                        let transaction = try await memberClient.memberPurchase(product)
                        let result: Bool
                        switch transaction.productType {
                        case .nonConsumable,
                                .consumable:
                            result = try await memberClient.payApple("\(transaction.id)")
                        default:
                            result = try await memberClient.payAppStore("\(transaction.id)",
                                                                            "\(transaction.originalID)")
                        }
                        await SVProgressHUD.dismiss()
                        if result {
                            await transaction.finish()
                            await send(.uploadUserProfile)
                            await SVProgressHUD.showSuccess(withStatus: "未完成购买")
                        } else {
                            await SVProgressHUD.showInfo(withStatus: "未完成购买")
                        }
                    } catch {
                        await SVProgressHUD.dismiss()
                        switch error {
                        case let storeError as StoreError:
                            switch storeError {
                            case .canceled:
                                await SVProgressHUD.showInfo(withStatus: "已取消购买")
                            case .validationFailed:
                                await SVProgressHUD.showError(withStatus: "验证检查未通过, 请稍候再试")
                            default:
                                break
                            }
                        default:
                            await SVProgressHUD.showError(withStatus: error.localizedDescription)
                        }
                    }
                }
            case .uploadUserProfile:
                return .run { _ in
                    _ = try await httpClient.getNewUserProfile()
                }
            case .recover:
                return .run { send in
                    await SVProgressHUD.show()
                    do {
                        for await result in try await memberClient.recover() {
                            await send(.recoverValidation(TaskResult { try memberClient.verification(result) }))
                        }
                    } catch {
                    }
                    await SVProgressHUD.dismiss()
                    await SVProgressHUD.showSuccess(withStatus: "购买已恢复")
                }
            case let .recoverValidation(.success(transaction)):
                return .run { send in
                    do {
                        switch transaction.productType {
                        case .nonConsumable,
                                .consumable:
                            let result = try await memberClient.payApple("\(transaction.id)")
                            await send(.recoverResponse(TaskResult {
                                .init(transaction: transaction,
                                      result: result)
                            }))
                        default:
                            let result = try await memberClient.payAppStore("\(transaction.id)",
                                                                            "\(transaction.originalID)")
                            await send(.recoverResponse(TaskResult {
                                .init(transaction: transaction,
                                      result: result)
                            }))
                        }
                    } catch {
#if DEBUG
                        
                        Logger(label: "Transaction.updates").info("Error===>\(error)")
#else
#endif
                    }
                }
            case let .recoverResponse(.success(response)):
                return .run { send in
                    if response.result {
                        await response.transaction.finish()
                        await send(.uploadUserProfile)
                    }
                }
            default:
                return .none
            }
        }
        .ifLet(\.$safariState, action: \.fullScreenCoverSafari) {
            MoreSafariFeature()
        }
    }
}
