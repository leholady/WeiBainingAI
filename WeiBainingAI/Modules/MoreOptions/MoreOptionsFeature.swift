//
//  MoreOptionsViewFeature.swift
//  WeiBainingAI
//
//  Created by MorningStar on 2023/11/24.
//

import ComposableArchitecture

@Reducer
struct MoreOptionsFeature {
    struct State: Equatable {
        var groups: [MoreOptionsGroupModel] = [.groupBalance, .groupMember, .groupHistory, .groupAbout]
        var balanceItems: [MoreBalanceItemModel] = []
    }
    
    enum Action: Equatable {
        case uploadBalanceItems
        case balanceItemsUpdate([MoreBalanceItemModel])
    }
    
    @Dependency(\.moreClient) var moreClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .uploadBalanceItems:
                return .run { send in
                   await send(.balanceItemsUpdate(try await moreClient.moreBalanceItems()))
                }
            case let .balanceItemsUpdate(items):
                state.balanceItems = items
                return .none
//            default:
//                return .none
            }
        }
    }
}

extension DependencyValues {
    var moreClient: MoreOptionsClient {
        get { self[MoreOptionsClient.self] }
        set { self[MoreOptionsClient.self] = newValue }
    }
}
