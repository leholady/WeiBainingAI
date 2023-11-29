//
//  SupportAssistantMakeView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/29.
//

import SwiftUI
import ComposableArchitecture

struct SupportAssistantMakeView: View {
    let store: StoreOf<SupportAssistantMakeFeature>
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 20) {
                Image(viewStore.makeStatus == .failure ? "error_default" : "generating_default")
                    .padding(.bottom, 10)
                Text(viewStore.makeStatus == .failure ? "生成失败" : "生成中")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: 0x666666))
                ZStack {
                    if viewStore.makeStatus != .failure {
                        GradientProgressView(progress: viewStore.progress,
                                             gradient: Gradient(colors: [Color(hex: 0xFCB990),
                                                                         Color(hex: 0xF77955)]))
                        .frame(width: 156, height: 12)
                    }
                    if viewStore.makeStatus == .failure {
                        Text("目前创作者过多，请稍后再试")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: 0x888888))
                    }
                }
                Button(action: {
                    switch viewStore.makeStatus {
                    case .failure:
                        viewStore.send(.startMark)
                    default:
                        dismiss()
                    }
                }, label: {
                    Text(viewStore.makeStatus == .failure ? "再试一次" : "取消")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 124, height: 50)
                        .background(Color(hex: 0x027AFF))
                        .cornerRadius(20)
                })
                .padding(.top, 10)
                if viewStore.makeStatus == .failure {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("取消")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: 0x027AFF))
                    })
                }
            }
            .onAppear {
                viewStore.send(.startMark)
            }
            .fullScreenCover(store: self.store.scope(state: \.$resultState,
                                                     action: \.fullScreenCoverResult)) { store in
                SupportAssistantResultView(store: store)
            }
        }
    }
}

#Preview {
    SupportAssistantMakeView(store: Store(initialState: SupportAssistantMakeFeature.State(extModel: SupportAssistantDetailsModel()), reducer: {
        SupportAssistantMakeFeature()
    }))
}
