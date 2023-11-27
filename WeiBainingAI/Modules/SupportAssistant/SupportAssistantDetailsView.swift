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
                            TextEditor(text: viewStore.binding(get: \.editorText, send: SupportAssistantDetailsFeature.Action.textEditorChanged))
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
                    .listRowInsets(EdgeInsets(top: 5,
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
                        SegmentedControl(items: viewStore.aspectImageFactors.compactMap { $0.rawValue }, selectedIndex: viewStore.binding(get: \.selectImageFactor, send: SupportAssistantDetailsFeature.Action.aspectImageFactorChanged))
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
                        SegmentedControl(items: viewStore.aspectStyles.compactMap { $0.rawValue }, selectedIndex: viewStore.binding(get: \.selectStyle, send: SupportAssistantDetailsFeature.Action.aspectStyleChanged))
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
                        SegmentedControl(items: viewStore.aspectRatios.compactMap { $0.rawValue }, selectedIndex: viewStore.binding(get: \.selectRatios, send: SupportAssistantDetailsFeature.Action.aspectRatioChanged))
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                
                .listStyle(.plain)
                .navigationTitle(viewStore.somthing)
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
    SupportAssistantDetailsView(store: Store(initialState: SupportAssistantDetailsFeature.State(somthing: "Hello World"),
                                             reducer: {
        SupportAssistantDetailsFeature()
    }))
}
