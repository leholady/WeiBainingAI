//
//  MessageListFeature.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/29.
//

import ComposableArchitecture
import Foundation

@Reducer
struct MessageListFeature {
    struct State: Equatable {
        /// 消息列表
        var messageList: [MessageItemModel] = []
        /// 输入提示词
        var inputTips: [String] = []
        /// 聊天配置信息
        var chatConfig: ChatRequestConfigMacro = .defaultConfig()
        /// 编辑框输入内容
        @BindingState var inputText: String = ""
        /// 偏好设置feature
        @PresentationState var modelSetup: ChatModelSetupFeature.State?
    }

    enum Action: Equatable {
        /// 读取历史配置
        case loadReqeustConfig
        /// 读取聊天消息
        case loadLocalMessages
        /// 更新消息列表
        case updateMessageList([MessageItemModel])
        case updateInputTips([String])
        /// 点击消息分享
        case didTapMsgShare
        /// 点击聊天偏好配置
        case chatModelSetupTapped
        /// 跳转聊天偏好配置
        case presentationModelSetup(PresentationAction<ChatModelSetupFeature.Action>)
    }

    @Dependency(\.msgAPIClient) var msgAPIClient
    @Dependency(\.msgListClient) var msgListClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
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
            case .chatModelSetupTapped:
                state.modelSetup = ChatModelSetupFeature.State()
                return .none
            case let .presentationModelSetup(.presented(.delegate(.updateChatModel(model)))):
                state.chatConfig.model = model
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
