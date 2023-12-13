//
//  LaunchConfigReducer.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/23.
//  启动配置Reducer

import ComposableArchitecture
import Reachability
import UIKit
import StoreKit
import Logging

@Reducer
struct LaunchConfigReducer {
    struct State: Equatable {
        var userProfile: UserProfileModel?
        /// 无网络
        var loadError: Bool = false
        
        var privacyAuth: Bool = false
        @PresentationState var safariState: MoreSafariFeature.State?
    }

    @Dependency(\.launchClient) var launchClient
    @Dependency(\.httpClient) var httpClient
    @Dependency(\.memberClient) var memberClient

    enum Action: Equatable {
        case launchApp
        case listenReachability(Reachability.Connection)
        case loadConfig
        case loadConfigSuccess(userProfile: UserProfileModel)
        case loadConfigFailure
        case loadPrivacyAuth
        case privacyAuthUpdate(Bool)
        case savePrivacyAuth(Bool)
        case dismissSafari(URL)
        case fullScreenCoverSafari(PresentationAction<MoreSafariFeature.Action>)
        
        case mamberUpdates
        case transactionValidation(TaskResult<Transaction>)
        case validationResponse(TaskResult<PremiumValidationResponse>)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .launchApp:
                state.loadError = false
                return .run { send in
                    for await reachable in await launchClient.reachable() {
                        await send(.listenReachability(reachable))
                    }
                }
            case let .listenReachability(connection):
                switch connection {
                case .unavailable:
                    state.loadError = true
                    return .none
                case .wifi, .cellular:
                    return .run { send in
                        await send(.loadConfig)
                    }
                }
            case .loadConfig:
                return .run { send in
                    do {
                        let userProfile = try await httpClient.getNewUserProfile()
                        await send(.loadConfigSuccess(userProfile: userProfile))
                    } catch {
                        await send(.loadConfigFailure)
                    }
                }
            case let .loadConfigSuccess(userProfile):
                state.userProfile = userProfile
                return .none
            case .loadConfigFailure:
                state.loadError = true
                return .none
            case .loadPrivacyAuth:
                return .run { send in
//                    launchClient.privacyAuthUpdate(false)
                    await send(.privacyAuthUpdate(launchClient.privacyAuth()))
                }
            case let .privacyAuthUpdate(privacy):
                state.privacyAuth = privacy
                return .run { send in
                    if privacy {
                        await send(.loadConfig)
                    }
                }
            case let .savePrivacyAuth(privacy):
                state.privacyAuth = privacy
                launchClient.privacyAuthUpdate(privacy)
                return .none
            case let .dismissSafari(url):
                state.safariState = MoreSafariFeature.State(url: url)
                return .none
            case .mamberUpdates:
                return .run { send in
                    for await result in await memberClient.updates() {
                        await send(.transactionValidation(TaskResult { try memberClient.verification(result) }))
                    }
                }
            case let .transactionValidation(.success(transaction)):
                return .run { send in
                    do {
                        switch transaction.productType {
                        case .autoRenewable:
                            let result = try await memberClient.payAppStore("\(transaction.id)",
                                                                            "\(transaction.originalID)")
                            await send(.validationResponse(TaskResult {
                                .init(transaction: transaction,
                                      result: result)
                            }))
                        default:
                            let result = try await memberClient.payApple("\(transaction.id)")
                            await send(.validationResponse(TaskResult {
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
            case let .validationResponse(.success(response)):
                return .run { send in
                    if response.result {
                        await response.transaction.finish()
                        await send(.loadConfig)
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
