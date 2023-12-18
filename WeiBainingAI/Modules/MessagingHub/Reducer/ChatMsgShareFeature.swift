//
//  ChatMsgShareFeature.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/4.
//

import ComposableArchitecture
import UIKit

@Reducer
struct ChatMsgShareFeature {
    struct State: Equatable {
        var userConfig: UserProfileModel?
        /// 分享的消息列
        var shareMsgList: [MessageItemDb] = []
        /// 原始消息
        var originalMsgList: [MessageItemDb] = []
        /// 是否全部分享
        var isShareAll: Bool = false
        /// 是否显示分享按钮
        @BindingState var showSharing: Bool = false
        /// 当前点击的消息分享
        var currentMsgItem: MessageItemDb?
        // 定义状态变量来标记何时需要进行截图
        @BindingState var shouldTakeSnapshot = false
        // 定义用来保存最后截图的状态变量
        var snapshotImage: UIImage?
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case loadChatShareTopics
        case dismissPage
        case initScreenshotStatus
        case didTakeSnapshot
        case takeSnapshotSucceeded(UIImage)
        case shareScreenshot(Bool)
    }

    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .loadChatShareTopics:
                if state.isShareAll == true {
                    state.shareMsgList = state.originalMsgList
                    return .none
                }
                // 获取当前消息在消息数组中的下标
                if let currentMsg = state.currentMsgItem {
                    let currentIndex = state.originalMsgList.firstIndex(where: { $0.identifier == currentMsg.identifier }) ?? 0
                    // 检查上一条消息和下一条消息是否存在，以及它们的内容
                    if currentMsg.roleType == .user {
                        if currentIndex < state.originalMsgList.count - 1 {
                            let nextMsg = state.originalMsgList[currentIndex + 1]
                            state.shareMsgList.removeAll()
                            state.shareMsgList.append(currentMsg)
                            state.shareMsgList.append(nextMsg)
                        }
                        return .none
                    } else {
                        if currentIndex > 0 {
                            let previousMsg = state.originalMsgList[currentIndex - 1]
                            state.shareMsgList.removeAll()
                            state.shareMsgList.append(previousMsg)
                            state.shareMsgList.append(currentMsg)
                        }
                        return .none
                    }
                } else {
                    return .none
                }

            case .initScreenshotStatus:
                state.shouldTakeSnapshot = false
                state.snapshotImage = nil
                return .none

            case .didTakeSnapshot:
                state.shouldTakeSnapshot = true
                return .none

            case let .takeSnapshotSucceeded(image):
                state.snapshotImage = image
                state.shouldTakeSnapshot = false
                return .run { send in
                    await send(.shareScreenshot(true))
                }

            case .dismissPage:
                return .run { _ in
                    await dismiss()
                }

            case let .shareScreenshot(result):
                state.showSharing = result
                return .none

            default:
                return .none
            }
        }
    }
}
