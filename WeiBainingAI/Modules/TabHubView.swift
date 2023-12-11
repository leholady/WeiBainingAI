//
//  TabHubView.swift
//  WeiBainingAI
//
//  Created by MorningStar on 2023/11/24.
//

import SwiftUI
import ComposableArchitecture

struct TabHubView: View {
    let store: StoreOf<TabHubFeature>
    
    var body: some View {
//        WithViewStore(store, observe: \.currentTab) { viewStore in
            TabView {
                MessagingHubView(store: store
                    .scope(state: \.messagingHubState, action: { .messagingHub($0) })
                )
                .tabItem {
                    Label("Chat", systemImage: "house")
                }
                .tag(TabHubFeature.Tab.messagingHub)
                
                SupportAssistantView(store: store
                    .scope(state: \.supportAssistantState, action: { .supportAssistant($0) })
                )
                .tabItem {
                    Label("Support", systemImage: "magnifyingglass")
                }
                .tag(TabHubFeature.Tab.supportAssistant)
                
                MoreOptionsView(store: store
                    .scope(state: \.moreOptionsState, action: { .moreOptions($0) })
                )
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(TabHubFeature.Tab.moreOptions)
            }
//        }
    }
}

@Reducer
struct TabHubFeature {
    enum Tab { case messagingHub, supportAssistant, moreOptions }
    
    struct State: Equatable {
        var messagingHubState = MessagingHubViewFeature.State()
        var supportAssistantState = SupportAssistantFeature.State()
        var moreOptionsState = MoreOptionsFeature.State()
        var currentTab: Tab = .messagingHub
    }
    
    enum Action: Equatable {
        case messagingHub(MessagingHubViewFeature.Action)
        case supportAssistant(SupportAssistantFeature.Action)
        case moreOptions(MoreOptionsFeature.Action)
        case tabSelected(Tab)
    }
    
    var body: some ReducerOf<Self> {

        Scope(state: \.messagingHubState, action: \.messagingHub) {
            MessagingHubViewFeature()
        }
        Scope(state: \.supportAssistantState, action: \.supportAssistant) {
            SupportAssistantFeature()
        }
        Scope(state: \.moreOptionsState, action: \.moreOptions) {
            MoreOptionsFeature()
        }
//        Reduce { _, _ in
//            return .none
//        }
//        ._printChanges()
    }
}

#Preview {
    TabHubView(store: Store(initialState: TabHubFeature.State(), reducer: {
        TabHubFeature()
    }))
}
