//
//  MoreSafariView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/1.
//

import SwiftUI
import ComposableArchitecture
import SafariServices

struct MoreSafariView: View {
    
    let store: StoreOf<MoreSafariFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            MYMoreSafariView(url: viewStore.url)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    MoreSafariView(store: Store(
        initialState: MoreSafariFeature.State(url: HttpConst.feedbackUrl),
        reducer: { MoreSafariFeature() }
    ))
}

@Reducer
struct MoreSafariFeature {
    struct State: Equatable {
        var url: URL
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

struct MYMoreSafariView: UIViewControllerRepresentable {
    let url: URL
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
}
