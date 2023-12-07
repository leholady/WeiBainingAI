//
//  MessageSendClient.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/6.
//

import Dependencies
import UIKit

struct MessageSendClient {
    // 处理发送消息
    var handleSendMsg: @Sendable (_ content: String,
                                  _ conversation: ConversationItemWCDB) async throws -> MessageItemWCDB
    // 处理接收消息
    var handleReceiveMsg: @Sendable (_ content: String,
                                     _ msgStatus: ChatErrorMacro,
                                     _ conversation: ConversationItemWCDB) async throws -> MessageItemWCDB
    // 重新发送消息
    // 分享消息
    // 删除消息
}

extension MessageSendClient: DependencyKey {
    static var liveValue: MessageSendClient {
        @Dependency(\.dbClient) var dbClient

        return Self(
            handleSendMsg: { content, conversation in
                let message = MessageItemWCDB(
                    conversationId: conversation.identifier,
                    role: MessageSendRole.user.rawValue,
                    content: content,
                    msgState: MessageSendState.success.rawValue,
                    timestamp: Date()
                )
                // 保存用户的消息
                try await dbClient.saveSingleMessage(message)
                // 更新话题最后一条信息
                try await dbClient.updateConversation(conversation, message)
                
                return message
            },
            handleReceiveMsg: { content, msgStatus, conversation in
                var message = MessageItemWCDB(
                    conversationId: conversation.identifier,
                    role: MessageSendRole.robot.rawValue,
                    content: content,
                    msgState: MessageSendState.generating.rawValue,
                    timestamp: Date()
                )
                if msgStatus == .success {
                    message.msgState = MessageSendState.success.rawValue
                } else {
                    message.content = "请求错误，请重试"
                    message.msgState = MessageSendState.failed.rawValue
                }
                // 保存机器人的消息
                try await dbClient.saveSingleMessage(message)
                // 更新话题最后一条信息
                try await dbClient.updateConversation(conversation, message)
                
                return message
            }
        )
    }
}

extension DependencyValues {
    var sendClient: MessageSendClient {
        get { self[MessageSendClient.self] }
        set { self[MessageSendClient.self] = newValue }
    }
}
