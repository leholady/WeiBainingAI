//
//  LaunchLoadView.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/23.
//

import ComposableArchitecture
import SwiftUI

struct LaunchLoadView: View {
    let store: StoreOf<LaunchConfigReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(content: {
                if viewStore.loadError {
                    VStack(alignment: .center, spacing: 0) {
                        Text("获取数据失败，请重试")
                            .foregroundColor(.black)
                            .font(.system(size: 20, weight: .medium))
                            .padding(.all, 20)

                        Button(action: {
                            store.send(.loadConfig)
                        }, label: {
                            Text("请点击页面重试")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .medium))
                                .padding(.all, 20)
                        })
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(2)
                        .padding(.bottom, 20)
                }
            })
            .task {
                viewStore.send(.launchApp)
            }
        }
    }
}

#Preview {
    LaunchLoadView(store: Store(initialState: LaunchConfigReducer.State(), reducer: {
        LaunchConfigReducer()
    }))
}
