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
                            switch item.type {
                            case .imageToAvatar,
                                    .imageToWallpaper:
                                viewStore.send(.dismissAlbum(item.type))
                            case .textToAvatar,
                                    .textToWallpaper:
                                viewStore.send(.dismissTextMake(item))
                            case .aiDiy:
                                viewStore.send(.dismissDetails(item))
                            case .lightShadow:
                                viewStore.send(.dismissLightShadow(item))
                            case .chat:
                                break
                            default:
                                break
                            }
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
                .fullScreenCover(store: self.store.scope(state: \.$lightShadowState,
                                                         action: \.fullScreenCoverLightShadow)) { store in
                    SupportAssistantLightShadowView(store: store)
                }
                .fullScreenCover(store: self.store.scope(state: \.$makeState,
                                                         action: \.fullScreenCoverMake)) { store in
                    SupportAssistantMakeView(store: store)
                }
                .fullScreenCover(store: self.store.scope(state: \.$textState,
                                                         action: \.fullScreenCoverTextMake)) { store in
                    SupportAssistantTextView(store: store)
                }
                .fullScreenCover(store: self.store.scope(state: \.$albumState,
                                                         action: \.fullScreenCoverAlbum)) { store in
                    ImagePickerView(store: store)
                }
                .fullScreenCover(store: self.store.scope(state: \.$details,
                                                         action: \.fullScreenCoverDetails)) { store in
                    SupportAssistantDetailsView(store: store)
                }
            }
            .background(Color(hex: 0xF6F6F6))
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    return SupportAssistantView(store: Store(
        initialState: SupportAssistantFeature.State(),
        reducer: { SupportAssistantFeature() }
    ))
}
