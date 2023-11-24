//
//  MoreOptionsView.swift
//  WeiBainingAI
//
//  Created by MorningStar on 2023/11/24.
//

import SwiftUI
import ComposableArchitecture

struct MoreOptionsView: View {
    let store: StoreOf<MoreOptionsFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text(viewStore.somthing)
            
        }
    }
}

#Preview {
    MoreOptionsView(store: Store(
        initialState: MoreOptionsFeature.State(),
        reducer: { MoreOptionsFeature() }
    ))
}
