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
                List(0..<viewStore.assistants.count, id: \.self) { index in
                    let item = viewStore.assistants[index]
                    SupportAssistantCell(model: item)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 5,
                                                  leading: 20,
                                                  bottom: 5,
                                                  trailing: 20))
                        .onTapGesture {
                            viewStore.send(.dismissDetails(item))
                        }
                }
                .background(Color.clear)
                .listStyle(.plain)
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
                .onAppear {
                    viewStore.send(.uploadAssistantItems)
                }
                .fullScreenCover(
                    store: self.store.scope(state: \.$details,
                                            action: \.fullScreenCoverDetails)) { store in
                                                SupportAssistantDetailsView(store: store)
                                            }
            }
            .background(Color(hex: 0xF6F6F6))
        }
    }
}

extension Color {
    init(hex: Int, alpha: Double = 1) {
        let components = (
            R: Double((hex >> 16) & 0xff) / 255,
            G: Double((hex >> 08) & 0xff) / 255,
            B: Double((hex >> 00) & 0xff) / 255
        )
        self.init(
            .sRGB,
            red: components.R,
            green: components.G,
            blue: components.B,
            opacity: alpha
        )
    }
}

#Preview {
    return SupportAssistantView(store: Store(
        initialState: SupportAssistantFeature.State(),
        reducer: { SupportAssistantFeature() }
    ))
}
