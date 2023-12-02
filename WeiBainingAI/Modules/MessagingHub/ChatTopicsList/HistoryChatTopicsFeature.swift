//
//  HistoryChatTopicsFeature.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/2.
//

import ComposableArchitecture
import Logging
import UIKit

struct HistoryChatTopicsFeature: Reducer {
    struct State: Equatable {
        var topicList: [TopicHistoryModel] = []
    }

    enum Action: Equatable {
        case loadChatTopics
        case chatTopicsLoaded(TaskResult<[TopicHistoryModel]>)
    }

    @Dependency(\.msgAPIClient) var msgAPIClient
    @Dependency(\.msgListClient) var msgListClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadChatTopics:
                return .run { send in
                    await send(.chatTopicsLoaded(TaskResult {
                        await msgListClient.loadLocalTopics(0)
                    }))
                }

            case let .chatTopicsLoaded(.success(items)):
                state.topicList = items
                return .none

            case let .chatTopicsLoaded(.failure(error)):
                Logger(label: "HistoryChatTopicsFeature").error("\(error)")
                state.topicList = []
                return .none
            }
        }
    }
}
