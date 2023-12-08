//
//  HistoryChatTopicsFeature.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/2.
//

import ComposableArchitecture
import Logging
import SVProgressHUD
import UIKit

@Reducer
struct ConversationListFeature {
    struct State: Equatable {
        var userConfig: UserProfileModel
        var conversationList: [ConversationItemDb] = []
        @BindingState var isEditing: Bool = false
        /// 跳转到聊天列表
        @PresentationState var chatPage: MessageListFeature.State?
        var isAllSelected: Bool = false
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case loadChatTopics
        case chatTopicsLoaded([ConversationItemDb])
        case didSelectEdit
        case didSelectConversation(ConversationItemDb)
        case didSelectAllConversation
        case didTapDeleteConversation
        case didTapStartNewChat
        case presentationNewChat(PresentationAction<MessageListFeature.Action>)
        case deleteSuccess
        case dismissTopics
        case delegate(Delegate)
        enum Delegate: Equatable {
            case updateConversationList(UserProfileModel)
        }
    }

    @Dependency(\.dbClient) var dbClient
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .loadChatTopics:
                let userId = state.userConfig.userId ?? ""
                return .run { send in
                    try await send(.chatTopicsLoaded(
                        await dbClient.loadConversation(userId)
                    ))
                } catch: { error, send in
                    Logger(label: "ConversationListFeature").error("\(error)")
                    await send(.chatTopicsLoaded([]))
                }
            case let .chatTopicsLoaded(results):
                state.conversationList = results
                return .none

            case .didSelectEdit:
                state.isEditing.toggle()
                return .none

            case let .didSelectConversation(result):
                if state.isEditing {
                    /// 在编辑模式下，选择对话
                    state.conversationList = state.conversationList.compactMap {
                        var item = $0
                        if item.identifier == result.identifier {
                            item.isSelected.toggle()
                        }
                        return item
                    }
                    /// 如果全部选择了，则全选按钮也要选中
                    let selectedCount = state.conversationList.filter { $0.isSelected == true }
                    if selectedCount.count == state.conversationList.count {
                        state.isAllSelected = true
                    } else {
                        state.isAllSelected = false
                    }
                    return .none
                } else {
                    /// 在正常模式下，选择对话
                    state.chatPage = MessageListFeature.State(userConfig: state.userConfig, conversation: result)
                    return .none
                }
            case .didSelectAllConversation:
                state.isAllSelected.toggle()
                state.conversationList = state.conversationList.compactMap {
                    var item = $0
                    item.isSelected = state.isAllSelected
                    return item
                }
                return .none

            case .didTapDeleteConversation:
                let conversationIds = state.conversationList.filter { $0.isSelected == true }
                if conversationIds.isEmpty {
                    SVProgressHUD.showError(withStatus: "请选择对话")
                    SVProgressHUD.dismiss(withDelay: 1.5)
                    return .none
                }
                return .run { send in
                    try await dbClient.deleteConversation(conversationIds)
                    await send(.deleteSuccess)
                }

            case .deleteSuccess:
                state.isAllSelected = false
                state.isEditing = false
                SVProgressHUD.showSuccess(withStatus: "删除成功")
                SVProgressHUD.dismiss(withDelay: 1.5)
                return .run { send in
                    await send(.loadChatTopics)
                }

            case .didTapStartNewChat:
                state.chatPage = MessageListFeature.State(
                    userConfig: state.userConfig,
                    conversation: nil
                )
                return .none

            case .dismissTopics:
                let config = state.userConfig
                return .run { send in
                    await send(.delegate(.updateConversationList(config)))
                    await dismiss()
                }
            default:
                return .none
            }
        }
        .ifLet(\.$chatPage, action: \.presentationNewChat) {
            MessageListFeature()
        }
    }
}
