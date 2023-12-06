//
//  MessageSeedFeature.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/2.
//

import ComposableArchitecture
import UIKit

@Reducer
struct MessageSeedFeature {
    struct State: Equatable {
        /// 聊天配置信息
        var chatConfig: ChatRequestConfigMacro = .defaultConfig()
        /// 用户配置信息
        var userConfig: UserProfileModel
        /// 是否在录制
        @BindingState var isRecording = false
    }

    enum Action: Equatable {
        /// 加载会话
        case loadConversation
        /// 发送消息流请求
        case sendStreamRequest(ConversationItemWCDB)
        /// 处理返回流
        case receiveStreamResult(String, ConversationItemWCDB)
        /// 消息发送成功处理
        case saveStreamResult(String, ConversationItemWCDB)

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

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            default:
                return .none
            }
        }
    }
}
