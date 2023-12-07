//
//  MessageListCellView.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/7.
//

import ComposableArchitecture
import SwiftUI
import SwiftUIX

// MARK: - 消息时间戳

/// 消息时间戳
struct MessageTimestampCell: View {
    var body: some View {
        HStack {
            Text("2023-06-22 22:20")
                .font(.system(size: 12))
                .foregroundColor(Color(hexadecimal6: 0xC7C7C7))
                .maxWidth(.infinity)
        }
    }
}

// MARK: - 消息列表显示项

struct MessageListCellView: View {
    let store: StoreOf<ChatMsgActionFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { (viewStore: ViewStoreOf<ChatMsgActionFeature>) in
            if viewStore.message.roleType == .user {
                MessageSenderCell(store: store)
            } else {
                MessageReceiveCell(store: store)
            }
        }
    }
}

// MARK: - 消息接收方

/// 消息接收方
struct MessageReceiveCell: View {
    let store: StoreOf<ChatMsgActionFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { (viewStore: ViewStoreOf<ChatMsgActionFeature>) in
            HStack(alignment: .top, spacing: 0) {
                Image(.chatavatar)
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .background(Color(hexadecimal6: 0xF77955))
                    .cornerRadius(15)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 10))

                ZStack(alignment: .center, content: {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(viewStore.message.content)
                            .font(.system(size: 14, weight: .regular))
                            .padding(EdgeInsets(top: 14, leading: 14, bottom: 0, trailing: 14))

                        HStack(alignment: .center, spacing: 0, content: {
                            if viewStore.message.msgStateType == .success {
                                Button(action: {
                                    viewStore.send(.copyTextToClipboard)
                                }, label: {
                                    Image(.chatIconCopyBlack)
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .padding(.all, 6)
                                })
                                Button(action: {
                                    viewStore.send(.shareMessage)
                                }, label: {
                                    Image(.chatIconShareBlack)
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .padding(.all, 6)
                                })
                            }
                            Button(action: {
                                viewStore.send(.deleteMessage)
                            }, label: {
                                Image(.chatIconDeleteBlack)
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .padding(.all, 6)
                            })
                        })
                        .padding(EdgeInsets(top: 0, leading: 8, bottom: 6, trailing: 0))
                    }
                    .background(Color(hexadecimal6: 0xF6F6F6))
                    .cornerRadius(10)

                })

                Spacer()
            }
            .padding(.trailing, Screen.width * 0.25)
            .padding(.vertical, 10)
        }
    }
}

// MARK: - 消息发送方

/// 消息发送方
struct MessageSenderCell: View {
    let store: StoreOf<ChatMsgActionFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { (viewStore: ViewStoreOf<ChatMsgActionFeature>) in
            HStack(alignment: .top, spacing: 0) {
                Spacer()
                ZStack(alignment: .center, content: {
                    VStack(alignment: .trailing, spacing: 5) {
                        Text(viewStore.message.content)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 14, leading: 14, bottom: 0, trailing: 14))

                        HStack(alignment: .center, spacing: 0, content: {
                            Button(action: {
                                viewStore.send(.regenerateAnswer)
                            }, label: {
                                Image(.chatIconRefreshWhite)
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .padding(.all, 6)
                            })

                            Button(action: {
                                viewStore.send(.copyTextToClipboard)
                            }, label: {
                                Image(.chatIconCopyWhite)
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .padding(.all, 6)
                            })

                            Button(action: {
                                viewStore.send(.shareMessage)
                            }, label: {
                                Image(.chatIconShareWhite)
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .padding(.all, 6)
                            })

                            Button(action: {
                                viewStore.send(.deleteMessage)
                            }, label: {
                                Image(.chatIconDeleteWhite)
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .padding(.all, 6)
                            })
                        })
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 8))
                    }
                    .background(Color(hexadecimal6: 0x027AFF))
                    .cornerRadius(10)

                })

                Image(.avatarUser)
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .background(Color(hexadecimal6: 0xF77955))
                    .cornerRadius(15)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
            }
            .padding(.leading, Screen.width * 0.25)
            .padding(.vertical, 10)
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    MessageReceiveCell(store: Store(
        initialState: ChatMsgActionFeature.State(
            id: 0,
            message: MessageItemDb(conversationId: 0, role: "", content: "", msgState: 0, timestamp: Date())
        ),
        reducer: { ChatMsgActionFeature() }
    ))
}
