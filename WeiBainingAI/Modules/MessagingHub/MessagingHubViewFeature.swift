//
//  MessagingHubViewFeature.swift
//  WeiBainingAI
//
//  Created by MorningStar on 2023/11/24.
//

import ComposableArchitecture
import Foundation
import Logging

@Reducer
struct MessagingHubViewFeature {
    struct State: Equatable {
        var suggestions: [SuggestionsModel] = []
        var topicList: [TopicHistoryModel] = []
    }

    enum Action: Equatable {
        /// 加载首页数据
        case loadDefaultData
        /// 更新首页数据
        case updateDefaultData(TaskResult<[SuggestionsModel]>)
        /// 更新历史话题数据
        case updateTopicData(TaskResult<[TopicHistoryModel]>)
        /// 点击历史话题
        case didTapHistoryButton
        /// 点击话题
        case startQuestions
        /// 点击建议
        case didTapSuggestion
    }

    @Dependency(\.msgAPIClient) var msgAPIClient
    @Dependency(\.msgListClient) var msgListClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadDefaultData:
                return .run { send in
                    await send(.updateDefaultData(TaskResult {
                        try await msgAPIClient.requestHomeProfile()
                    }))
                    await send(.updateTopicData(TaskResult {
                         await msgListClient.loadLocalTopics(0)
                    }))
                }
            case let .updateDefaultData(.success(items)):
                state.suggestions = items
                return .none

            case let .updateDefaultData(.failure(error)):
                Logger(label: "MessagingHubViewFeature").error("\(error)")
                state.suggestions = []
                return .none

            case let .updateTopicData(.success(items)):
                state.topicList = items
                return .none

            case let .updateTopicData(.failure(error)):
                Logger(label: "MessagingHubViewFeature").error("\(error)")
                state.topicList = []
                return .none

            case .startQuestions:
                return .none

            default:
                return .none
            }
        }
    }
}
