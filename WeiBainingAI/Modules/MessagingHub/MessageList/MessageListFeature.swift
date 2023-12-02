//
//  MessageListFeature.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/29.
//

import ComposableArchitecture
import Foundation
import Logging

@Reducer
struct MessageListFeature {
    struct State: Equatable {
        /// 消息列表
        var messageList: [MessageItemModel] = []
        /// 输入提示词
        var inputTips: [String] = []
        /// 聊天配置信息
        var chatConfig: ChatRequestConfigMacro = .defaultConfig()
        /// 用户配置信息
        var userConfig: UserProfileModel?
        /// 偏好设置feature
        @PresentationState var modelSetup: ChatModelSetupFeature.State?
        /// 编辑框输入内容
        @BindingState var inputText: String = ""
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        /// 读取历史配置
        case loadChatConfig
        /// 读取聊天消息
        case loadLocalMessages
        /// 更新配置信息到界面
        case updateChatConfig(ChatRequestConfigMacro)
        case updateUserConfig(TaskResult<UserProfileModel>)
        /// 更新消息列表
        case updateMessageList([MessageItemModel])
        case updateInputTips([String])
        /// 发送消息
        case sendMessage
        /// 消息发送成功处理
        case sendMessageResult(String)
        /// 点击消息分享
        case didTapMsgShare
        /// 点击聊天偏好配置
        case chatModelSetupTapped
        /// 跳转聊天偏好配置
        case presentationModelSetup(PresentationAction<ChatModelSetupFeature.Action>)
    }

    @Dependency(\.msgAPIClient) var msgAPIClient
    @Dependency(\.httpClient) var httpClient
    @Dependency(\.msgListClient) var msgListClient

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .loadChatConfig:
                return .run { send in
                    await send(.updateUserConfig(TaskResult {
                        try await httpClient.currentUserProfile()
                    }))
                    await send(.updateChatConfig(
                        await msgListClient.loadReqeustConfig()
                    ))
                }
            case let .updateChatConfig(result):
                state.chatConfig = result
                if let user = state.userConfig {
                    state.chatConfig.userId = user.userId ?? ""
                }
                return .none

            case let .updateUserConfig(.success(result)):
                state.userConfig = result
                return .none

            case let .updateUserConfig(.failure(error)):
                Logger(label: "v").error("\(error)")
                return .none

            case .loadLocalMessages:
                return .run { send in
                    await send(.updateMessageList(
                        await msgListClient.loadLocalMessages(TopicHistoryModel(userId: 0, timestamp: Date(), topic: "", reply: ""))
                    ))
                    try await send(.updateInputTips(
                        await msgAPIClient.loadInputTips()
                    ))
                }
            case let .updateMessageList(items):
                state.messageList = items
                return .none

            case let .updateInputTips(tips):
                state.inputTips = tips
                return .none

            case .sendMessage:
                let msg = state.inputText
                let config = state.chatConfig
                return .run { send in
                    for try await message in try await httpClient.sendMessage(msg, config) {
                        await send(.sendMessageResult(message))
                    }
                } catch: { error, _ in
                    Logger(label: "v").error("\(error)")
                }
            case let .sendMessageResult(result):
                Logger(label: "sendMessageResult =>").info("\(result)")
                return .none

            case .chatModelSetupTapped:
                state.modelSetup = ChatModelSetupFeature.State()
                return .none

            case let .presentationModelSetup(.presented(.delegate(.updateChatModel(model)))):
                state.chatConfig = model
                return .none

            default:
                return .none
            }
        }
        .ifLet(\.$modelSetup, action: \.presentationModelSetup) {
            ChatModelSetupFeature()
        }
    }
}
