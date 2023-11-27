//
//  SupportAssistantView.swift
//  WeiBainingAI
//
//  Created by MorningStar on 2023/11/24.
//

import SwiftUI
import ComposableArchitecture

struct SupportAssistantView: View {
    let store: StoreOf<SupportAssistantFeature>
    var body: some View {
        NavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewStore.assistants) { item in
                            SupportAssistantCell(model: item)
                                .onTapGesture {
//                                    viewStore.send(.popDetails)
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("助手")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.black)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Image("home_icon_member")
                }
            }
            .background(Color.gray.opacity(0.1))
        }
    }
}

#Preview {
    SupportAssistantView(store: Store(
        initialState: SupportAssistantFeature.State(),
        reducer: { SupportAssistantFeature() }
    ))
}
