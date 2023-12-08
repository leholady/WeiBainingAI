//
//  MoreOptionsViewFeature.swift
//  WeiBainingAI
//
//  Created by MorningStar on 2023/11/24.
//

import ComposableArchitecture
import Foundation
import Logging
import SVProgressHUD
import StoreKit

@Reducer
struct MoreOptionsFeature {
    struct State: Equatable {
        var groups: [MoreOptionsGroupModel] = []
        var balanceItems: [MoreBalanceItemModel] = []
        @PresentationState var safariState: MoreSafariFeature.State?
        @PresentationState var premiumState: PremiumMemberFeature.State?
    }
    
    enum Action: Equatable {
        case uploadGroups([MoreOptionsGroupModel])
        case uploadBalanceItems
        case balanceItemsUpdate(TaskResult<[MoreBalanceItemModel]>)
        case dismissSafari(URL)
        case fullScreenCoverSafari(PresentationAction<MoreSafariFeature.Action>)
        case dismissPremium
        case fullScreenCoverPremium(PresentationAction<PremiumMemberFeature.Action>)
        case uploadUserProfile
        case recover
        case recoverValidation(TaskResult<Transaction>)
        case recoverResponse(TaskResult<PremiumValidationResponse>)
        case hudShow
        case hudDismiss
        case hudSuccess(String)
    }
    
    @Dependency(\.moreClient) var moreClient
    @Dependency(\.memberClient) var memberClient
    @Dependency(\.httpClient) var httpClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .uploadGroups(groups):
                state.groups = groups
                return .none
            case .uploadBalanceItems:
                return .run { send in
                    await send(.balanceItemsUpdate(
                        TaskResult {
                            try await moreClient.moreBalanceItems()
                        }
                    ))
                }
            case let .balanceItemsUpdate(.success(items)):
                state.balanceItems = items
                return .run { send in
                    await send(.uploadGroups([.groupBalance, .groupMember, .groupHistory, .groupAbout]))
                }
            case .balanceItemsUpdate(.failure):
                return .run { send in
                    await send(.uploadGroups([.groupMember, .groupHistory, .groupAbout]))
                }
            case let .dismissSafari(url):
                state.safariState = MoreSafariFeature.State(url: url)
                return .none
            case .dismissPremium:
                state.premiumState = PremiumMemberFeature.State()
                return .none
            case .uploadUserProfile:
                return .run { _ in
                    _ = try await httpClient.getNewUserProfile()
                }
            case .recover:
                return .run { send in
                    await send(.hudShow)
                    do {
                        for await result in try await memberClient.recover() {
                            await send(.recoverValidation(TaskResult { try memberClient.verification(result) }))
                        }
                    } catch {
                    }
                    await send(.hudDismiss)
                    await send(.hudSuccess("购买已恢复"))
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
            case .hudShow:
                SVProgressHUD.show()
                return .none
            case .hudDismiss:
                SVProgressHUD.dismiss()
                return .none
            case let .hudSuccess(message):
                SVProgressHUD.showSuccess(withStatus: message)
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$safariState, action: \.fullScreenCoverSafari) {
            MoreSafariFeature()
        }
        .ifLet(\.$premiumState, action: \.fullScreenCoverPremium) {
            PremiumMemberFeature()
        }
    }
}

extension DependencyValues {
    var moreClient: MoreOptionsClient {
        get { self[MoreOptionsClient.self] }
        set { self[MoreOptionsClient.self] = newValue }
    }
}
