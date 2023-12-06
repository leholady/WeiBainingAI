//
//  ChatMsgActionFeature.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/7.
//

import ComposableArchitecture
import SVProgressHUD
import UIKit

@Reducer
struct ChatMsgActionFeature {
    struct State: Equatable, Hashable, Identifiable {
        let id: UUID
        let message: MessageItemWCDB
    }

    enum Action: Equatable {
        /// 复制消息
        case copyTextToClipboard
        /// 分享消息
        case shareMessage
        /// 删除消息
        case deleteMessage
        /// 重新生成回答
        case regenerateAnswer
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .copyTextToClipboard:
                UIPasteboard.general.string = state.message.content
                SVProgressHUD.showSuccess(withStatus: "已复制到剪切板")
                SVProgressHUD.dismiss(withDelay: 1.5)
                return .none

            case .shareMessage:
                return .none

            case .deleteMessage:
                return .none

            case .regenerateAnswer:
                return .none
            }
        }
    }
}
