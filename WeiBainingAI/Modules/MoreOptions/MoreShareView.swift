//
//  MoreShareView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/11.
//

import SwiftUI
import SwiftUIX
import ComposableArchitecture

struct MoreShareView: View {
    let store: StoreOf<MoreShareFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            AppActivityView(activityItems: [viewStore.shareModel.title as Any,
                                            viewStore.shareModel.content as Any,
                                            viewStore.shareModel.url as Any])
        }
    }
}

#Preview {
    MoreShareView(store: Store(
        initialState: MoreShareFeature.State(shareModel: MoreShareModel(title: "分享")),
        reducer: { MoreShareFeature() }
    ))
}

@Reducer
struct MoreShareFeature {
    struct State: Equatable {
        var shareModel: MoreShareModel
    }
    
    enum Action: Equatable {
        case normal
    }
    
    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .normal:
                return .none
            }
        }
    }
}
