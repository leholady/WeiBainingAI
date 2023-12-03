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
        /// 用户配置信息
        var userConfig: UserProfileModel?
        /// 跳转到聊天列表
        @PresentationState var msgItem: MessageListFeature.State?
        /// 跳转到历史记录
        @PresentationState var historyItem: ChatTopicsListFeature.State?
//        @PresentationState var topicItem: TopicListFeature.State?
    }

    enum Action: Equatable {
        /// 加载首页数据
        case loadDefaultData
        /// 加载用户配置
        case loadUserConfig
        /// 更新用户配置
        case updateUserConfig(TaskResult<UserProfileModel>)
        /// 更新首页数据
        case updateDefaultData(TaskResult<[SuggestionsModel]>)
        /// 更新历史话题数据
        case updateTopicData(TaskResult<[TopicHistoryModel]>)
        /// 点击历史消息
        case didTapHistoryMsg
        case presentationHistoryMsg(PresentationAction<ChatTopicsListFeature.Action>)
        /// 点击发起新聊天
        case didTapStartNewChat
        case presentationNewChat(PresentationAction<MessageListFeature.Action>)
        /// 点击建议
        case didTapSuggestion
        /// 点击话题
        case didTapTopicChat
    }

    @Dependency(\.msgAPIClient) var msgAPIClient
    @Dependency(\.httpClient) var httpClient
    @Dependency(\.msgListClient) var msgListClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadDefaultData:
                return .run { send in
                    await send(.updateDefaultData(TaskResult {
                        try await msgAPIClient.requestHomeProfile()
                    }))
                    await send(.updateUserConfig(TaskResult {
                        try await httpClient.currentUserProfile()
                    }))
                    await send(.updateTopicData(TaskResult {
                        await msgListClient.loadLocalTopics(0)
                    }))
                }
            case let .updateUserConfig(.success(result)):
                state.userConfig = result
                return .none

            case let .updateUserConfig(.failure(error)):
                Logger(label: "v").error("\(error)")
                return .none

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

            case .didTapStartNewChat:
                state.msgItem = MessageListFeature.State()
                return .none
                
            case .didTapHistoryMsg:
                state.historyItem = ChatTopicsListFeature.State()
                return .none

            default:
                return .none
            }
        }
        .ifLet(\.$msgItem, action: \.presentationNewChat) {
            MessageListFeature()
        }
        .ifLet(\.$historyItem, action: \.presentationHistoryMsg) {
            ChatTopicsListFeature()
        }
    }
}
