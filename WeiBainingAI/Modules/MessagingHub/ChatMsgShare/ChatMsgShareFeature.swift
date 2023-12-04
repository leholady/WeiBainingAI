//
//  ChatMsgShareFeature.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/4.
//

import ComposableArchitecture
import UIKit

@Reducer
struct ChatMsgShareFeature {
    struct State: Equatable {
        var userConfig: UserProfileModel?
    }

    enum Action: Equatable {
        case loadChatShareTopics
    }

    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .loadChatShareTopics:
                return .none
            }
        }
    }
}
