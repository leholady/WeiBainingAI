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
            switch viewStore.userProfile {
            case .none:
                ReloadConfigView(isReload: viewStore.loadError,
                                 privacyAuth: true) {
                    viewStore.send(.launchApp)
                }
                .onAppear {
                    viewStore.send(.launchApp)
                }
            default:
                TabHubView(store: Store(initialState: TabHubFeature.State(), reducer: {
                    TabHubFeature()
                }))
            }
        }
    }
}

/// 显示重新加载视图
struct ReloadConfigView: View {
    var isReload: Bool
    var privacyAuth: Bool
    var action: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
            VStack {
                Image("img_icon")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding(.top, 120)
                Spacer()
                if isReload {
                    Text("获取数据失败，请重试")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .padding(.all, 20)
                    Text("请点击页面重试")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                        .padding(.bottom, 20)
                }
            }
            .padding(30)
        }
        .background(.black)
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    LaunchLoadView(store: Store(initialState: LaunchConfigReducer.State(), reducer: {
        LaunchConfigReducer()
    }))
}
