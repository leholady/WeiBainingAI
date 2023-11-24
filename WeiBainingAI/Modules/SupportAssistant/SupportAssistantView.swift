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
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text(viewStore.somthing)
            
        }
    }
}

#Preview {
    SupportAssistantView(store: Store(
        initialState: SupportAssistantFeature.State(),
        reducer: { SupportAssistantFeature() }
    ))
}
