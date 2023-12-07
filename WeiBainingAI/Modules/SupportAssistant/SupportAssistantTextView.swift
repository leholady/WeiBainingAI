//
//  SupportAssistantTextView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/6.
//

import SwiftUI
import ComposableArchitecture

struct SupportAssistantTextView: View {
    
    let store: StoreOf<SupportAssistantTextFeature>
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                List {
                    SupportAssistantDetailsTextCell(title: "文字提示",
                                                    placeholder: "输入所需的内容和风格例如：太空行走的小猫",
                                                    text: viewStore.$editorText,
                                                    editorHeight: 220)
                    if viewStore.aspectStyles.count > 1 {
                        SupportAssistantDetailsSegmentedCell(title: "风格",
                                                             items: viewStore.aspectStyles.compactMap { $0.title },
                                                             select: viewStore.$selectStyle)
                    }
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
    SupportAssistantTextView(store: Store(initialState: SupportAssistantTextFeature.State(textTitle: "text",
                                                                                          editType: .textToAvatar, aspectStyles: [.style9]), reducer: {
        SupportAssistantTextFeature()
    }))
}
