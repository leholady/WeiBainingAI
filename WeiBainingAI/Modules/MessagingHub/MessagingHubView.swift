//
//  MessagingHubView.swift
//  WeiBainingAI
//
//  Created by MorningStar on 2023/11/24.
//

import SwiftUI
import ComposableArchitecture

struct MessagingHubView: View {
    let store: StoreOf<MessagingHubViewFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            
            Button {
                viewStore.send(.change)
            } label: {
                Text(viewStore.somthing)
            }

        }
    }
}

#Preview {
    MessagingHubView(store: Store(
        initialState: MessagingHubViewFeature.State(),
        reducer: { MessagingHubViewFeature() }
    ))
}
