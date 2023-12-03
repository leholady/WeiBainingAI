//
//  HistoryChatTopicsFeature.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/2.
//

import ComposableArchitecture
import Logging
import UIKit

struct ChatTopicsListFeature: Reducer {
    struct State: Equatable {
        var topicList: [ConversationItemWCDB] = []
    }

    enum Action: Equatable {
        case loadChatTopics
        case chatTopicsLoaded(TaskResult<[ConversationItemWCDB]>)
        case dismissTopics
    }

    @Dependency(\.msgAPIClient) var msgAPIClient
    @Dependency(\.msgListClient) var msgListClient
    @Dependency(\.dbClient) var dbClient
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadChatTopics:
                return .run { send in
                    await send(.chatTopicsLoaded(TaskResult {
                       try await dbClient.loadConversation("")
                    }))
                }

            case let .chatTopicsLoaded(.success(items)):
                state.topicList = items
                return .none

            case let .chatTopicsLoaded(.failure(error)):
                Logger(label: "HistoryChatTopicsFeature").error("\(error)")
                state.topicList = []
                return .none

            case .dismissTopics:
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}
