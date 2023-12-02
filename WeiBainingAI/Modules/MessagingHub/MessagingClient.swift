//
//  MessagingClient.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/28.
//

import Dependencies
import UIKit

struct MessageAPIClient {
    /// 请求首页数据
    var requestHomeProfile: @Sendable () async throws -> [SuggestionsModel]
    /// 发起聊天
    var requestChatMst: @Sendable (_ msg: MessageItemModel) async throws -> Bool
    /// 加载输入提示语
    var loadInputTips: @Sendable () async throws -> [String]
}

extension MessageAPIClient: DependencyKey {
    static var liveValue: MessageAPIClient {
        previewValue
    }
}

extension MessageAPIClient: TestDependencyKey {
    static var previewValue: MessageAPIClient {
        Self {
            [
                SuggestionsModel(title: "写一份关于太空旅行的市场分析报告"),
                SuggestionsModel(title: "写一首古代散文诗歌"),
                SuggestionsModel(title: "给热爱旅行的妻子写一封情人节信"),
                SuggestionsModel(title: "写一篇关于二手车买卖市场趋势的调查报告"),
                SuggestionsModel(title: "写一首反映工业文明的现代叙事诗")
            ]
        } requestChatMst: { _ in
            true
        } loadInputTips: {
            [
                "历史",
                "诗歌",
                "散文"
            ]
        }
    }

    static var testValue: MessageAPIClient = Self(
        requestHomeProfile: unimplemented("\(Self.self).requestHomeProfile"),
        requestChatMst: unimplemented("\(Self.self).requestChatMst"),
        loadInputTips: unimplemented("\(Self.self).loadInputTips")
    )
}

extension DependencyValues {
    var msgAPIClient: MessageAPIClient {
        get { self[MessageAPIClient.self] }
        set { self[MessageAPIClient.self] = newValue }
    }
}
