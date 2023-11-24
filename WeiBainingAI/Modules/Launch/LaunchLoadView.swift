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
        WithViewStore(store, observe: { $0 }) { _ in
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

/// 显示重新加载视图
struct ReloadConfigView: View {
    var isReload: Bool
    var privacyAuth: Bool
    let store: StoreOf<LaunchConfigReducer>

    var body: some View {
        ZStack(content: {
            if isReload {
                Text("获取数据失败，请重试")
                    .foregroundColor(.black)
                    .font(.system(size: 20, weight: .medium))
                    .padding(.all, 20)

                Button(action: {
                    store.send(.loadConfig)
                }, label: {
                    Text("请点击页面重试")
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .medium))
                        .padding(.all, 20)
                })
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
                    .padding(.bottom, 20)
            }
        })
    }
}

#Preview {
    LaunchLoadView(store: Store(initialState: LaunchConfigReducer.State(), reducer: {
        LaunchConfigReducer()
    }))
}
