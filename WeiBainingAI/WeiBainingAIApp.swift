//
//  WeiBainingAIApp.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/23.
//

import ComposableArchitecture
import SwiftUI

@main
struct WeiBainingAIApp: App {
    let launchStore = Store(initialState: LaunchConfigReducer.State()) {
        LaunchConfigReducer()
    }

    var body: some Scene {
        WindowGroup {
            WithViewStore(launchStore, observe: { $0 }) { viewStore in
                if viewStore.userProfile != nil {
                    TabHubView(store: Store(initialState: TabHubFeature.State(), reducer: {
                        TabHubFeature()
                    })
                    )
                } else {
                    LaunchLoadView(store: launchStore)
                }
            }
        }
    }

    init() {
        initNavigationStyle()
    }

    // 初始化导航栏
    private func initNavigationStyle() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowImage = UIImage() // 底部阴影
        appearance.shadowColor = .clear // 底部阴影颜色
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
