//
//  SupportAssistantDetailsView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/27.
//

import SwiftUI
import ComposableArchitecture

struct SupportAssistantDetailsView: View {
    let store: StoreOf<SupportAssistantDetailsFeature>
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                List {
                    SupportAssistantDetailsTextCell(title: "文字提示",
                                                    placeholder: "输入所需的内容和风格例如：太空行走的小猫",
                                                    text: viewStore.$editorText)
                    SupportAssistantDetailsImageCell(title: "图像提示",
                                                     imageData: viewStore.selectImageData) {
                        viewStore.send(.dismissAlbum)
                    } deleteAction: {
                        viewStore.send(.selectImageDetele)
                    }
                    SupportAssistantDetailsSegmentedCell(title: "图像参考度",
                                                         items: viewStore.aspectImageFactors.compactMap { $0.title },
                                                         select: viewStore.$selectImageFactor)
                    SupportAssistantDetailsSegmentedCell(title: "风格",
                                                         items: viewStore.aspectStyles.compactMap { $0.title },
                                                         select: viewStore.$selectStyle)
                    SupportAssistantDetailsSegmentedCell(title: "纵横比",
                                                         items: viewStore.aspectRatios.compactMap { $0.title },
                                                         select: viewStore.$selectRatios)
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
                .navigationTitle(viewStore.assistantTitle)
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
                .fullScreenCover(store: self.store.scope(state: \.$albumState,
                                                         action: \.fullScreenCoverAlbum)) { store in
                    ImagePickerView(store: store)
                }
            }
            .background(Color(hex: 0xF6F6F6))
        }
    }
}

#Preview {
    SupportAssistantDetailsView(store: Store(initialState: SupportAssistantDetailsFeature.State(assistantTitle: "Hello World"),
                                             reducer: {
        SupportAssistantDetailsFeature()
    }))
}
