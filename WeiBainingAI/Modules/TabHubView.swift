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
    
    @State var currentTab: TabHubFeature.Tab = .messagingHub
    
    var body: some View {
//        WithViewStore(store, observe: \.currentTab) { viewStore in
        TabView(selection: $currentTab) {
                MessagingHubView(store: store
                    .scope(state: \.messagingHubState, action: { .messagingHub($0) })
                )
                .tabItem {
                    Label("Chat",
                          image: currentTab == .messagingHub ? "home_icon_home_sel" : "home_icon_home_unsel")
//                    Label("Chat", systemImage: "house")
                }
                .tag(TabHubFeature.Tab.messagingHub)
                
                SupportAssistantView(store: store
                    .scope(state: \.supportAssistantState, action: { .supportAssistant($0) })
                )
                .tabItem {
                    Label("Support", image: currentTab == .supportAssistant ? "home_icon_assistant_sel" : "home_icon_assistant_unsel")
//                    Label("Support", systemImage: "magnifyingglass")
                }
                .tag(TabHubFeature.Tab.supportAssistant)
                
                MoreOptionsView(store: store
                    .scope(state: \.moreOptionsState, action: { .moreOptions($0) })
                )
                .tabItem {
                    Label("Settings", image: currentTab == .moreOptions ? "home_icon_more_sel" : "home_icon_more_unsel")
//                    Label("Settings", systemImage: "gear")
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
