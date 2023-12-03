//
//  MessageListFeature.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/29.
//

import ComposableArchitecture
import Foundation
import Logging
import Speech
import SVProgressHUD

@Reducer
struct MessageListFeature {
    struct State: Equatable {
        /// 消息列表
        var messageList: [MessageItemModel] = []
        /// 输入提示词
        var inputTips: [String] = []
        /// 聊天配置信息
        var chatConfig: ChatRequestConfigMacro = .defaultConfig() {
            didSet {
                debugPrint("chatConfig => \(chatConfig)")
            }
        }

        /// 用户配置信息
        var userConfig: UserProfileModel?
        /// 偏好设置feature
        @PresentationState var modelSetup: ChatModelSetupFeature.State?
        /// 编辑框输入内容
        @BindingState var inputText: String = ""
        /// 录音状态
        var recordState: Bool = false
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
        /// 关闭当前页面
        case dismissPage
        /// 检查录音识别权限
        case checkSpeechAuth
        /// 点击开始录音
        case startRecord
        /// 正在录音
        case recordingResult(String)
        /// 点击完成录音
        case finishRecord
        /// 没有录音权限
        case noRecordAuth
    }

    @Dependency(\.msgAPIClient) var msgAPIClient
    @Dependency(\.httpClient) var httpClient
    @Dependency(\.msgListClient) var msgListClient
    @Dependency(\.dismiss) var dismiss

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

            case let .updateUserConfig(.success(result)):
                state.userConfig = result
                return .none

            case let .updateUserConfig(.failure(error)):
                Logger(label: "v").error("\(error)")
                return .none

            case let .updateChatConfig(result):
                state.chatConfig = result
                if let user = state.userConfig {
                    state.chatConfig.userId = user.userId ?? ""
                }
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
                    Logger(label: "sendMessage").error("\(error)")
                }
            case let .sendMessageResult(result):
                Logger(label: "sendMessageResult =>").info("\(result)")
                return .none

            case .chatModelSetupTapped:
                let config = state.chatConfig
                state.modelSetup = ChatModelSetupFeature.State(chatConfig: config)
                return .none

            case let .presentationModelSetup(.presented(.delegate(.updateChatModel(model)))):
                state.chatConfig = model
                return .none

            case .dismissPage:
                return .run { _ in await dismiss() }

            case .checkSpeechAuth:
                return .run { send in
                    await msgListClient.checkSpeechAuth() ? await send(.startRecord) : await send(.noRecordAuth)
                }

            case .startRecord:
                state.recordState = true
                return .run { send in
                    for try await text in try await msgListClient.startVoiceToText() {
                        await send(.recordingResult(text))
                    }
                }
            case let .recordingResult(result):
                Logger(label: "recordingResult =>").info("\(result)")
                state.inputText = result
                return .none

            case .finishRecord:
                state.recordState = false
                return .none

            case .noRecordAuth:
                SVProgressHUD.showError(withStatus: "没有语音权限")
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
