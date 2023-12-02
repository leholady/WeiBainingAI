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
        var selectModelId: Int = 1
        /// 选择风格
        @BindingState var selectStyleIndex: Int = 0

        var chatModelList: [ChatModelConfig] = [
            ChatModelConfig(id: 1, title: "GPT-3.5 Turbo", desc: "Turbo 针对对话进行了优化"),
            ChatModelConfig(id: 2, title: "GPT-4", desc: "GPT-4可以遵循复杂的指令并准确地解决难题。")
        ]
        var chatStyleItem: [ChatStyleType] = [.creativity, .balance, .accurate]
    }

    enum Action: BindableAction, Equatable {
        /// 聊天风格值发生改变
        case binding(BindingAction<State>)
        /// 选择聊天模型
        case selectChatModel(index: Int)
        /// 关闭视图
        case dismissConfig

        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case updateChatModel(ChatRequestConfigMacro)
        }
    }

    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case let .selectChatModel(index):
                state.selectModelId = index
                return .none

            case .dismissConfig:
                let chatConfig = ChatRequestConfigMacro.defaultConfig()
                return .run { send in
                    await send(.delegate(.updateChatModel(chatConfig)))
                    await dismiss()
                }
            default:
                return .none
            }
        }
    }
}
