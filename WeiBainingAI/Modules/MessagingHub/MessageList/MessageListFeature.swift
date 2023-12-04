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
        var messageList: [MessageItemWCDB] = []
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
        /// 当前会话
        var conversation: ConversationItemWCDB?
        /// 录音状态
        var recordState: Bool = false
        /// 响应状态
        var responding: Bool = false
        /// 偏好设置feature
        @PresentationState var modelSetup: ChatModelSetupFeature.State?
        /// 编辑框输入内容
        @BindingState var inputText: String = ""
        /// 流返回数据
        @BindingState var streamMsg = ""
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        /// 读取历史配置
        case loadChatConfig
        /// 读取聊天消息
        case loadLocalMessages(ConversationItemWCDB)
        /// 更新配置信息到界面
        case updateChatConfig(ChatRequestConfigMacro)
        case updateUserConfig(TaskResult<UserProfileModel>)

        /// 更新消息列表
        case updateMessageList(MessageItemWCDB)
        case loadMessageList([MessageItemWCDB])
        case updateInputTips([String])

        /// 加载会话
        case loadConversation
        /// 发送消息流请求
        case sendStreamRequest(ConversationItemWCDB)
        /// 处理返回流
        case receiveStreamResult(String, ConversationItemWCDB)
        /// 消息发送成功处理
        case saveStreamResult(String, ConversationItemWCDB)

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
    @Dependency(\.dbClient) var dbClient
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
                state.chatConfig.userId = state.userConfig?.userId ?? ""
                if let conversation = state.conversation {
                    return .run { send in
                        try await send(.loadMessageList(
                            await dbClient.loadMessages(conversation)
                        ))
                    }
                }
                return .none

            case let .loadLocalMessages(conversation):
                return .run { send in
                    try await send(.loadMessageList(
                        await dbClient.loadMessages(conversation)
                    ))
                }
            case let .loadMessageList(items):
                state.messageList = items
                return .none

            case let .updateInputTips(tips):
                state.inputTips = tips
                return .none

            case .loadConversation:
                let config = state.chatConfig
                let conversation = state.conversation
                return .run { send in
                    if let existingCon = conversation {
                        await send(.sendStreamRequest(existingCon))
                    } else {
                        let createCon = try await dbClient.createConversation(config.userId)
                        await send(.sendStreamRequest(createCon))
                    }
                } catch: { error, _ in
                    Logger(label: "loadConversation").error("\(error)")
                }

            case let .sendStreamRequest(conversation):
                state.conversation = conversation
                let config = state.chatConfig
                let msgText = state.inputText
                state.inputText = ""
                state.streamMsg = "思考中..."
                return .run { send in
                    let msgItem = MessageItemWCDB(
                        conversationId: conversation.identifier,
                        role: MessageSendRole.user.rawValue,
                        content: msgText,
                        msgState: MessageSendState.success.rawValue,
                        timestamp: Date()
                    )
                    // 保存用户的消息
                    try await dbClient.saveSingleMessage(msgItem)
                    // 更新话题最后一条信息
                    try await dbClient.updateConversation(conversation, msgItem)
                    // 刷新列表
                    try await send(.loadMessageList(
                        await dbClient.loadMessages(conversation)
                    ))
                    // 请求返回的消息
                    for try await message in try await httpClient.sendMessage(msgText, config) {
                        await send(.receiveStreamResult(message, conversation))
                    }
                } catch: { error, _ in
                    Logger(label: "sendStreamRequest").error("\(error)")
                    await SVProgressHUD.showError(withStatus: error.localizedDescription)
                }

            case let .receiveStreamResult(result, conversation):
                if !state.responding {
                    state.streamMsg = ""
                    state.responding = true
                }
                if result == ChatErrorMacro.success.rawValue {
                    state.responding = false
                    let msg = state.streamMsg
                    return .run { send in
                        await send(.saveStreamResult(msg, conversation))
                    }
                } else if result == ChatErrorMacro.unknownError.rawValue {
                    state.responding = false
                    return .run { send in
                        await send(.saveStreamResult("请求错误，请重试", conversation))
                    }
                } else {
                    state.streamMsg += result
                }
                return .none

            case let .saveStreamResult(result, conversation):
                let msgItem = MessageItemWCDB(
                    conversationId: conversation.identifier,
                    role: MessageSendRole.robot.rawValue,
                    content: result,
                    msgState: MessageSendState.success.rawValue,
                    timestamp: Date()
                )
                // 保存机器人的消息
                Logger(label: "saveStreamResult").info("\(msgItem)")
                return .run { send in
                    try await dbClient.saveSingleMessage(msgItem)
                    // 更新话题最后一条信息
                    try await dbClient.updateConversation(conversation, msgItem)
                    try await send(.loadMessageList(
                        await dbClient.loadMessages(conversation)
                    ))
                }

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
