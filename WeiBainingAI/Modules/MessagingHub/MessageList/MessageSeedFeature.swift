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
        /// 点击开始录音
        case startRecord
        /// 正在录音
        case recording
        /// 点击完成录音
        case finishRecord
        /// 录音转换为文字
        case recordToText
        /// 发送文字
        case sendText
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .startRecord:
                state.isRecording = true
                return .none
            case .recording:
                return .none
            case .finishRecord:
                state.isRecording = false
                return .none
            case .recordToText:
                return .none
            case .sendText:
                return .none
            }
        }
    }
}
