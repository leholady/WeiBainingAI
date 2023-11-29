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
    }

    enum Action: Equatable {
        /// 从数据库加载消息数据
        case loadMessageList
        /// 更新消息列表
        case updateMessageList([MessageItemModel])
        case updateInputTips([String])
        /// 点击消息分享
        case didTapMsgShare
    }

    @Dependency(\.messageAPIClient) var messageAPIClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadMessageList:
                return .run { send in
                    try await send(.updateMessageList(await messageAPIClient.loadMsgList(0)))
                    try await send(.updateInputTips(await messageAPIClient.loadInputTips()))
                }
            case let .updateMessageList(items):
                state.messageList = items
                return .none
            case let .updateInputTips(tips):
                state.inputTips = tips
                return .none
            default:

                return .none
            }
        }
    }
}
