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
        var headerTitle: String = "Premium会员"
        @BindingState var pageSelect: Int = 0
        var pageItems: [PremiumMemberPageModel] = []
        @PresentationState var safariState: MoreSafariFeature.State?
        @BindingState var itemSelects: [Int]?
        var isVipState: Bool = false
        var vipExpireTime: String?
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
        case recover
        case recoverValidation(TaskResult<Transaction>)
        case recoverResponse(TaskResult<PremiumValidationResponse>)
        case uploadMemberStatus
        case vipStateUpload(Bool)
        case vipExpireTime(String)
        case hudShow
        case hudDismiss
        case hudFailure(String)
        case hudInfo(String)
        case hudSuccess(String)
        case delegate(Delegate)
        enum Delegate: Equatable {
            case purchaseCompleted
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.memberClient) var memberClient
    @Dependency(\.httpClient) var httpClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.$pageSelect):
                state.headerTitle = state.pageSelect < state.pageItems.count ? state.pageItems[state.pageSelect].pageState.headerTitle : "Premium会员"
                return .none
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
                        await send(.hudShow)
                        let transaction = try await memberClient.memberPurchase(product)
                        let result: Bool
                        switch transaction.productType {
                        case .autoRenewable:
                            result = try await memberClient.payAppStore("\(transaction.id)",
                                                                        "\(transaction.originalID)")
                        default:
                            result = try await memberClient.payApple("\(transaction.id)")
                        }
                        await send(.hudDismiss)
                        if result {
                            await transaction.finish()
                            await send(.uploadMemberStatus)
                            await send(.hudSuccess("已成功开通会员"))
                            await send(.delegate(.purchaseCompleted))
                        } else {
                            await send(.hudInfo("开通会员失败，如已付款请重启应用试试"))
                        }
                    } catch {
                        await send(.hudDismiss)
                        switch error {
                        case let storeError as StoreError:
                            switch storeError {
                            case .canceled:
                                await send(.hudFailure("已取消购买"))
                            case .validationFailed:
                                await send(.hudFailure("验证检查未通过, 请稍候再试"))
                            default:
                                break
                            }
                        default:
                            await send(.hudFailure(error.localizedDescription))
                        }
                    }
                }
            case .recover:
                return .run { send in
                    await send(.hudShow)
                    do {
                        for await result in try await memberClient.recover() {
                            await send(.recoverValidation(TaskResult { try memberClient.verification(result) }))
                        }
                        await send(.hudDismiss)
                        await send(.hudSuccess("购买已恢复"))
                    } catch {
                        await send(.hudDismiss)
                        switch error as? StoreKitError {
                        case .userCancelled:
                            await send(.hudFailure("已取消恢复"))
                        default:
                            break
                        }
                    }
                }
            case let .recoverValidation(.success(transaction)):
                return .run { send in
                    do {
                        switch transaction.productType {
                        case .autoRenewable:
                            let result = try await memberClient.payAppStore("\(transaction.id)",
                                                                            "\(transaction.originalID)")
                            await send(.recoverResponse(TaskResult {
                                .init(transaction: transaction,
                                      result: result)
                            }))
                        default:
                            let result = try await memberClient.payApple("\(transaction.id)")
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
                        await send(.uploadMemberStatus)
                    }
                }
            case .uploadMemberStatus:
                return .run { send in
                    do {
                        let user = try await memberClient.userProfile()
                        await send(.vipStateUpload(user.isVip ?? false))
                        if let vipExpireTime = user.vipExpireTime,
                           vipExpireTime > 0 {
                            let date = Date(timeIntervalSince1970: TimeInterval(vipExpireTime))
                            await send(.vipExpireTime("有效期: \(date.timeFormat)"))
                        }
                    } catch {
                    }
                }
            case let .vipStateUpload(isVip):
                state.isVipState = isVip
                return .none
            case let .vipExpireTime(expireTime):
                state.vipExpireTime = expireTime
                return .none
            case .hudShow:
                SVProgressHUD.show()
                return .none
            case .hudDismiss:
                SVProgressHUD.dismiss()
                return .none
            case let .hudSuccess(message):
                SVProgressHUD.showSuccess(withStatus: message)
                return .none
            case let .hudInfo(message):
                SVProgressHUD.showInfo(withStatus: message)
                return .none
            case let .hudFailure(message):
                SVProgressHUD.showError(withStatus: message)
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$safariState, action: \.fullScreenCoverSafari) {
            MoreSafariFeature()
        }
    }
}
