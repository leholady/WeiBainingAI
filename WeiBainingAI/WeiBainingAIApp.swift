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
            LaunchLoadView(store: launchStore)
        }
    }
}
