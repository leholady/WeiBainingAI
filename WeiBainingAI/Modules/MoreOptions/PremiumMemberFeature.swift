//
//  PremiumMemberFeature.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/2.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PremiumMemberFeature {

    struct State: Equatable {
        var headerItems: [MemberHeaderItemModel] = [.gtp3, .gtp4, .assistant, .server, .ads, .update]
        @BindingState var pageSelect: Int = 0
        var pageItems: [PremiumMemberPageModel] = []
        @PresentationState var safariState: MoreSafariFeature.State?
//        @BindingState var premiumModel: PremiumMemberModel?
//        @BindingState var quotaModel: PremiumMemberModel?
    }
    
    enum Action: BindableAction, Equatable {
        case premiumDismiss
        case uploadPageItems
        case pageItemsUpdate(TaskResult<[PremiumMemberPageModel]>)
        case binding(BindingAction<State>)
        case dismissSafari(URL)
        case fullScreenCoverSafari(PresentationAction<MoreSafariFeature.Action>)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.memberClient) var memberClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .premiumDismiss:
                return .run { _ in
                    await self.dismiss()
                }
            case .uploadPageItems:
                return .run { send in
                    await send(.pageItemsUpdate(
                        TaskResult {
                            try await memberClient.premiumMemberPageItems()
                        }
                    ))
                }
            case let .pageItemsUpdate(.success(items)):
                state.pageItems = items
                return .none
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
    var memberClient: PremiumMemberClient {
        get { self[PremiumMemberClient.self] }
        set { self[PremiumMemberClient.self] = newValue }
    }
}
