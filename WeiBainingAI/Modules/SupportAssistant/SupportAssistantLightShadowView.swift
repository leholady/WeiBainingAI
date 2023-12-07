//
//  SupportAssistantLightShadowView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/7.
//

import SwiftUI
import ComposableArchitecture

struct SupportAssistantLightShadowView: View {
    
    let store: StoreOf<SupportAssistantLightShadowFeature>
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                List {
                    SupportAssistantLightShadowTextCell(title: "光影文字",
                                                    placeholder: "输入所需的文字内容",
                                                    text: viewStore.$lightShadowText)
                    SupportAssistantDetailsSegmentedCell(title: "风格",
                                                         items: viewStore.aspectStyles.compactMap { $0.title },
                                                         select: viewStore.$selectStyle)
                    RoundedRectangle(cornerRadius: 20)
                        .overlay(content: {
                            Text("生成")
                                .foregroundColor(.white)
                        })
                        .frame(height: 50)
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .foregroundColor(Color(hex: 0x027AFF))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .onTapGesture {
                            viewStore.send(.dismissMake)
                        }
                }
                .listStyle(.plain)
                .navigationTitle(viewStore.textTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image("icon_back")
                        })
                    }
                }
                .fullScreenCover(store: self.store.scope(state: \.$makeState,
                                                         action: \.fullScreenCoverMake)) { store in
                    SupportAssistantMakeView(store: store)
                }
            }
            .background(Color(hex: 0xF6F6F6))
        }
    }
}

#Preview {
    SupportAssistantLightShadowView(store: Store(initialState: SupportAssistantLightShadowFeature.State(textTitle: "Hello, World!"), reducer: {
        SupportAssistantLightShadowFeature()
    }))
}
