//
//  MoreOptionsViewFeature.swift
//  WeiBainingAI
//
//  Created by MorningStar on 2023/11/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct MoreOptionsFeature {
    struct State: Equatable {
        var groups: [MoreOptionsGroupModel] = []
        var balanceItems: [MoreBalanceItemModel] = []
        @PresentationState var safariState: MoreSafariFeature.State?
    }
    
    enum Action: Equatable {
        case uploadGroups([MoreOptionsGroupModel])
        case uploadBalanceItems
        case balanceItemsUpdate(TaskResult<[MoreBalanceItemModel]>)
        case dismissSafari(URL)
        case fullScreenCoverSafari(PresentationAction<MoreSafariFeature.Action>)
    }
    
    @Dependency(\.moreClient) var moreClient
    
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
            default:
                return .none
            }
        }
        .ifLet(\.$safariState, action: \.fullScreenCoverSafari) {
            MoreSafariFeature()
        }
    }
}

extension DependencyValues {
    var moreClient: MoreOptionsClient {
        get { self[MoreOptionsClient.self] }
        set { self[MoreOptionsClient.self] = newValue }
    }
}
