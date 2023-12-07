//
//  ChatModelSetupFeature.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/30.
//

import ComposableArchitecture
import UIKit

@Reducer
struct ChatModelSetupFeature {
    struct State: Equatable {
        /// 选择模型
        var selectModelId: Int = 0
        var chatConfig: ChatRequestConfigMacro
        /// 选择风格
        @BindingState var selectStyleIndex: Int = 0
        /// 附加消息计数
        @BindingState var msgCount: Int = 0
        /// 附加消息Token
        @BindingState var msgTokens: Int = 0

        var chatModelList: [ChatModelType] = [.gpt3_5, .gpt4]
        var chatStyleItem: [ChatTemperatureType] = [.creativity, .balance, .accurate]
    }

    enum Action: BindableAction, Equatable {
        /// 聊天风格值发生改变
        case binding(BindingAction<State>)
        /// 加载聊天配置
        case loadChatConfig
        /// 选择聊天模型
        case selectChatModel(index: Int)
        /// 聊天配置缓存
        case saveChatConfig
        /// 更新消息计数
        case updateMsgCount(Double)
        /// 更新消息Token
        case updateMsgTokens(Double)
        /// 关闭视图
        case dismissConfig
        case delegate(Delegate)
        enum Delegate: Equatable {
            case updateChatModel(ChatRequestConfigMacro)
        }
    }

    @Dependency(\.msgListClient) var msgListClient
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                if state.selectStyleIndex == 0 {
                    state.chatConfig.temperature = .creativity
                } else if state.selectStyleIndex == 1 {
                    state.chatConfig.temperature = .balance
                } else if state.selectStyleIndex == 2 {
                    state.chatConfig.temperature = .accurate
                }
                state.chatConfig.msgCount = state.msgCount
                state.chatConfig.maxtokens = state.msgTokens
                return .none
            case .loadChatConfig:
                state.selectModelId = (state.chatConfig.model == .gpt3_5) ? 0 : 1
                switch state.chatConfig.temperature {
                case .creativity:
                    state.selectStyleIndex = 0
                case .balance:
                    state.selectStyleIndex = 1
                case .accurate:
                    state.selectStyleIndex = 2
                }
                state.msgCount = state.chatConfig.msgCount
                state.msgTokens = state.chatConfig.maxtokens
                return .none
            case let .selectChatModel(index):
                state.selectModelId = index
                state.chatConfig.model = (index == 0) ? .gpt3_5 : .gpt4
                return .none
            case .dismissConfig:
                let chatConfig = state.chatConfig
                return .run { send in
                    _ = try await msgListClient.saveReqeustConfig(chatConfig)
                    await send(.delegate(.updateChatModel(chatConfig)))
                    await dismiss()
                }
            case let .updateMsgCount(count):
                state.msgCount = Int(count * 10)
                state.chatConfig.msgCount = state.msgCount
                return .none
            case let .updateMsgTokens(sliderValue):
                let actualValue = sliderValue * 4000
                let roundedValue = (actualValue / 10).rounded() * 10
                state.msgTokens = Int(roundedValue)
                state.chatConfig.maxtokens = state.msgTokens
                return .none
            default:
                return .none
            }
        }
    }
}
