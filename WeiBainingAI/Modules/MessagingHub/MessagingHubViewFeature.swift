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
        var conversations: [ConversationItemWCDB] = []
        /// 用户配置信息
        var userConfig: UserProfileModel?
        /// 跳转到聊天列表
        @PresentationState var msgItem: MessageListFeature.State?
        /// 跳转到历史记录
        @PresentationState var historyItem: ConversationListFeature.State?
    }

    enum Action: Equatable {
        /// 加载首页数据
        case loadDefaultConfig
        /// 更新用户配置
        case updateUserConfig(TaskResult<UserProfileModel>)
        /// 更新首页建议数据
        case updateSuggestionsData(TaskResult<[SuggestionsModel]>)
        /// 更新历史话题数据
        case updateConversationData(TaskResult<[ConversationItemWCDB]>)
        /// 点击历史消息
        case didTapHistoryMsg
        case presentationHistoryMsg(PresentationAction<ConversationListFeature.Action>)
        /// 点击发起新聊天
        case didTapStartNewChat(ConversationItemWCDB?)
        case presentationNewChat(PresentationAction<MessageListFeature.Action>)
        /// 点击建议
        case didTapSuggestion
        /// 点击话题
        case didTapTopicChat
    }

    @Dependency(\.msgAPIClient) var msgAPIClient
    @Dependency(\.httpClient) var httpClient
    @Dependency(\.dbClient) var dbClient
    @Dependency(\.msgListClient) var msgListClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadDefaultConfig:
                return .run { send in
                    await send(.updateUserConfig(TaskResult {
                        try await httpClient.currentUserProfile()
                    }))
                    await send(.updateSuggestionsData(TaskResult {
                        try await msgAPIClient.requestHomeProfile()
                    }))
                }
            case let .updateUserConfig(.success(result)):
                state.userConfig = result
                return .run { send in
                    _ = try await dbClient.initDatabase()
                    await send(.updateConversationData(TaskResult {
                        try await dbClient.loadConversation(result.userId)
                    }))
                }
            case let .updateUserConfig(.failure(error)):
                Logger(label: "v").error("\(error)")
                return .none

            case let .updateSuggestionsData(.success(items)):
                state.suggestions = items
                return .none

            case let .updateSuggestionsData(.failure(error)):
                Logger(label: "MessagingHubViewFeature").error("\(error)")
                state.suggestions = []
                return .none

            case let .updateConversationData(.success(items)):
                state.conversations = items
                return .none

            case let .updateConversationData(.failure(error)):
                Logger(label: "MessagingHubViewFeature").error("\(error)")
                state.conversations = []
                return .none

            case let .didTapStartNewChat(result):
                state.msgItem = MessageListFeature.State(
                    userConfig: state.userConfig,
                    conversation: result
                )
                return .none

            case .didTapHistoryMsg:
                if let userConfig = state.userConfig {
                    state.historyItem = ConversationListFeature.State(userConfig: userConfig)
                }
                return .none

            case let .presentationHistoryMsg(.presented(.delegate(.updateConversationList(config)))):
                return .run { send in
                    await send(.updateConversationData(TaskResult {
                        try await dbClient.loadConversation(config.userId)
                    }))
                }
            default:
                return .none
            }
        }
        .ifLet(\.$msgItem, action: \.presentationNewChat) {
            MessageListFeature()
        }
        .ifLet(\.$historyItem, action: \.presentationHistoryMsg) {
            ConversationListFeature()
        }
    }
}
