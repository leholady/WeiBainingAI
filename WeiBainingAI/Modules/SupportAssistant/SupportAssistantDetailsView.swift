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
                    VStack(alignment: .leading) {
                        Text("文字提示")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: 0x666666))
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: viewStore.$editorText)
                                .padding(6)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .frame(minHeight: 120)
                                .background(.white)
                                .cornerRadius(10)
                            if viewStore.editorText.isEmpty {
                                Text("输入所需的头像内容和风格例如：太空行走的小猫")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: 0x999999))
                                    .padding(.horizontal, 11)
                                    .padding(.vertical, 14)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 40,
                                              leading: 20,
                                              bottom: 25,
                                              trailing: 20))
                    VStack(alignment: .leading) {
                        Text("图像提示")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: 0x666666))
                        Image("assistant_icon_picture")
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 5,
                                              leading: 20,
                                              bottom: 25,
                                              trailing: 20))
                    VStack(alignment: .leading) {
                        Text("图像参考度")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: 0x666666))
                        SegmentedControl(items: viewStore.aspectImageFactors.compactMap { $0.title }, selectedIndex: viewStore.$selectImageFactor)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 5,
                                              leading: 20,
                                              bottom: 25,
                                              trailing: 20))
                    VStack(alignment: .leading) {
                        Text("风格")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: 0x666666))
                        SegmentedControl(items: viewStore.aspectStyles.compactMap { $0.title }, selectedIndex: viewStore.$selectStyle)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 5,
                                              leading: 20,
                                              bottom: 25,
                                              trailing: 20))
                    VStack(alignment: .leading) {
                        Text("纵横比")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: 0x666666))
                        SegmentedControl(items: viewStore.aspectRatios.compactMap { $0.title }, selectedIndex: viewStore.$selectRatios)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 5,
                                              leading: 20,
                                              bottom: 80,
                                              trailing: 20))
                    RoundedRectangle(cornerRadius: 20)
                        .overlay(content: {
                            Text("生成")
                                .foregroundColor(.white)
                        })
                        .frame(height: 50)
                        .padding(.horizontal, 20)
                        .foregroundColor(Color(hex: 0x027AFF))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .onTapGesture {
                            viewStore.send(.generateStart)
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
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image("more_icon_share")
                        })
                    }
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
