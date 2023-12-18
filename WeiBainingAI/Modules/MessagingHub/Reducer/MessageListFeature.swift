//
//  MessageListFeature.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/29.
//  消息列表处理

import Combine
import ComposableArchitecture
import Foundation
import Logging
import Speech
import SVProgressHUD
@Reducer
struct MessageListFeature {
    struct State: Equatable {
        /// 消息列表
        var messageList: [MessageItemDb] = []
        /// 输入提示词
        var inputTips: [String] = []
        /// 聊天配置信息
        var chatConfig: ChatRequestConfigMacro = .defaultConfig()
        /// 用户配置信息
        var userConfig: UserProfileModel?
        /// 当前会话
        var conversation: ConversationItemDb?
        /// 录音状态
        var recordState: Bool = false
        /// 响应状态
        @BindingState var responding: Bool = false
        /// 偏好设置feature
        @PresentationState var setupPage: ChatModelSetupFeature.State?
        /// 分享内容
        @PresentationState var sharePage: ChatMsgShareFeature.State?
        /// 编辑框输入内容
        @BindingState var inputText: String = ""
        /// 流返回数据
        @BindingState var streamMsg: String = ""

        /// 处理cell状态
        var msgTodos: IdentifiedArrayOf<ChatMsgActionFeature.State> = []
        var msgListPublisher: AnyPublisher<[MessageItemDb], Never> {
            Just(messageList)
                .eraseToAnyPublisher()
        }

        var keyboardWillShowPublisher: AnyPublisher<CGRect, Never> {
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap {
                    $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                }
                .debounce(for: .milliseconds(100), scheduler: RunLoop.main) // 去抖
                .eraseToAnyPublisher()
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case actionTodos(IdentifiedActionOf<ChatMsgActionFeature>)
        /// 读取历史配置
        case loadChatConfig
        /// 读取聊天消息
        case loadLocalMessages(ConversationItemDb)
        /// 更新配置信息到界面
        case updateChatConfig(ChatRequestConfigMacro)
        case updateUserConfig(TaskResult<UserProfileModel>)
        /// 更新消息列表
        case updateMessageList(MessageItemDb)
        case loadMessageList([MessageItemDb])
        case updateInputTips([String])
        /// 加载会话
        case loadConversation
        /// 发送消息流请求
        case sendStreamRequest(ConversationItemDb)
        /// 处理返回流
        case receiveStreamResult(String, ConversationItemDb)
        /// 消息生成
        case msgThinking
        /// 消息发送成功处理
        case updateStreamResult(ConversationItemDb)
        /// 点击消息分享
        case msgShareTapped(MessageItemDb?)
        /// 跳转聊天偏好配置
        case presentationMsgShare(PresentationAction<ChatMsgShareFeature.Action>)
        /// 点击聊天偏好配置
        case chatModelSetupTapped
        /// 跳转聊天偏好配置
        case presentationModelSetup(PresentationAction<ChatModelSetupFeature.Action>)
        /// 关闭当前页面
        case dismissPage
        /// 检查录音识别权限
        case checkSpeechAuth
        /// 改变录音状态
        case changeRecordState(Bool)
        /// 正在录音
        case recordingResult(String)
        /// 没有录音权限
        case noRecordAuth
    }

    @Dependency(\.httpClient) var httpClient
    @Dependency(\.msgListClient) var msgListClient
    @Dependency(\.sendClient) var sendClient
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
                state.msgTodos = IdentifiedArray(uniqueElements: items.map { item in
                    ChatMsgActionFeature.State(id: item.id, message: item)
                })
                return .none
            case let .updateInputTips(tips):
                state.inputTips = tips
                return .none
            case .checkSpeechAuth:
                UIApplication.shared.endEditing()
                return .run { send in
                    await msgListClient.checkSpeechAuth() ? await send(.changeRecordState(true)) : await send(.noRecordAuth)
                }
            case let .changeRecordState(result):
                state.recordState = result
                return .run { send in
                    if result {
                        for try await text in try await msgListClient.startVoiceToText() {
                            await send(.recordingResult(text))
                        }
                    } else {
                        await msgListClient.stopVoiceRecognition()
                    }
                }
            case let .recordingResult(result):
                state.inputText = result
                return .none
            case .noRecordAuth:
                SVProgressHUD.showError(withStatus: "没有语音权限")
                SVProgressHUD.dismiss(withDelay: 1.5)
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
                }
            case .msgThinking:
                state.streamMsg = "正在思考..."
                state.responding = true
                return .none

            case let .sendStreamRequest(conversation):
                state.conversation = conversation
                let chatConfig: (String, ChatRequestConfigMacro) = (state.inputText, state.chatConfig)
                let messageList = state.messageList
                state.inputText = ""
                return .run { send in
                    _ = try await sendClient.handleSendMsg(chatConfig.0, conversation)
                    // 刷新列表
                    await send(.updateStreamResult(conversation))
                    await send(.msgThinking)
                    // 请求返回的消息
                    for try await message in try await msgListClient.handleStreamData(chatConfig, messageList) {
                        await send(.receiveStreamResult(message, conversation))
                    }
                }
            case let .receiveStreamResult(result, conversation):
                if state.streamMsg == "正在思考..." {
                    state.streamMsg = ""
                }
                if let charMacro = ChatErrorMacro(rawValue: result), charMacro == .success || charMacro == .unknownError {
                    let message = state.streamMsg
                    return .run { send in
                        _ = try await sendClient.handleReceiveMsg(message, charMacro, conversation)
                        await send(.updateStreamResult(conversation))
                    }
                } else {
                    state.streamMsg += result
                }
                return .none
            case let .updateStreamResult(conversation):
                state.streamMsg = ""
                state.responding = false
                return .run { send in
                    try await send(.loadMessageList(
                        await dbClient.loadMessages(conversation)
                    ))
                }
            case let .msgShareTapped(result):
                if state.messageList.isEmpty { return .none }
                if let message = result {
                    state.sharePage = ChatMsgShareFeature.State(
                        userConfig: state.userConfig,
                        originalMsgList: state.messageList,
                        isShareAll: false,
                        currentMsgItem: message
                    )
                } else {
                    state.sharePage = ChatMsgShareFeature.State(
                        originalMsgList: state.messageList,
                        isShareAll: true
                    )
                }
                return .none

            case .chatModelSetupTapped:
                let config = state.chatConfig
                state.setupPage = ChatModelSetupFeature.State(chatConfig: config)
                return .none

            case let .presentationModelSetup(.presented(.delegate(.updateChatModel(model)))):
                state.chatConfig = model
                return .none

            case let .actionTodos(.element(id: _, action: .delegate(.regenerate(model)))):
                guard let conversation = state.conversation else {
                    return .none
                }
                let chatConfig: (String, ChatRequestConfigMacro) = (model, state.chatConfig)
                let messageList = state.messageList
                return .run { send in
                    _ = try await sendClient.handleSendMsg(model, conversation)
                    // 刷新列表
                    await send(.updateStreamResult(conversation))
                    await send(.msgThinking)
                    // 请求返回的消息
                    for try await message in try await msgListClient.handleStreamData(chatConfig, messageList) {
                        await send(.receiveStreamResult(message, conversation))
                    }
                }
            case let .actionTodos(.element(id: id, action: .shareMessage)):
                let message = state.messageList.first(where: { $0.id == id })
                return .run { send in
                    await send(.msgShareTapped(message))
                }

            case let .actionTodos(.element(id: id, action: .deleteMessage)):
                if let message = state.messageList.first(where: { $0.id == id }) {
                    let messageList = state.messageList
                    return .run { send in
                        try await send(.loadMessageList(
                            await dbClient.deleteMessageGroup(message, messageList)
                        ))
                    } catch: { error, send in
                        Logger(label: "deleteMessage").error("\(error)")
                        await SVProgressHUD.showError(withStatus: "删除失败")
                        await SVProgressHUD.dismiss(withDelay: 1.5)
                        await send(.loadMessageList(messageList))
                    }
                }
                return .none

            case .dismissPage:
                return .run { _ in await dismiss() }
            default:
                return .none
            }
        }
        .ifLet(\.$setupPage, action: \.presentationModelSetup) {
            ChatModelSetupFeature()
        }
        .ifLet(\.$sharePage, action: \.presentationMsgShare) {
            ChatMsgShareFeature()
        }
        .forEach(\.msgTodos, action: \.actionTodos) {
            ChatMsgActionFeature()
        }
    }
}
