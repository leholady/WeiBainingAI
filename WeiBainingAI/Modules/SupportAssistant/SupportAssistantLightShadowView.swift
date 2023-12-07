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
    SupportAssistantLightShadowView(store: Store(initialState: SupportAssistantLightShadowFeature.State(textTitle: "光影特效",
                                                                                                        depictText: "时尚摄影肖像，女孩，白色长裙晚礼服，腮红，唇彩，微笑，浅棕色头发，落肩，飘逸的羽毛装饰礼服，蓬松长发，柔和的光线，美丽的阴影，低调，逼真，原始照片，自然的皮肤纹理，逼真的眼睛和脸部细节，超现实主义，超高分辨率，4K，最佳质量，杰作，项链，乳白色",
                                                                                                        aspectStyles: [.style8, .style12, .style16, .style22, .style25]), reducer: {
        SupportAssistantLightShadowFeature()
    }))
}
