//
//  MessagingHubViewFeature.swift
//  WeiBainingAI
//
//  Created by MorningStar on 2023/11/24.
//

import ComposableArchitecture
import Foundation

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
        case updateDefaultData([SuggestionsModel])
        /// 更新历史话题数据
        case updateTopicData([TopicHistoryModel])
        /// 点击历史话题
        case didTapHistoryButton
        /// 点击话题
        case startQuestions
        /// 点击建议
        case didTapSuggestion
    }

    @Dependency(\.messageAPIClient) var messageAPIClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadDefaultData:
                return .run { send in
                    await send(.updateDefaultData(try await messageAPIClient.requestHomeProfile()))
                    await send(.updateTopicData(try await messageAPIClient.loadHistoryTopic()))
                }
            case let .updateDefaultData(items):
                state.suggestions = items
                return .none
            case let .updateTopicData(items):
                state.topicList = items
                return .none
            case .startQuestions:
    
                return .none
            default:
           
                return .none
            }
        }
    }
}
