//
//  MessageListView.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/28.
//

import ComposableArchitecture
import SwiftUI
import SwiftUIX

struct MessageListView: View {
    let store: StoreOf<MessageListFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(alignment: .center, spacing: 0, content: {
                    List {
                        ForEach(viewStore.messageList, id: \.self) { message in
                            if message.isSender {
                                MessageSenderCell(msg: message)
                            } else {
                                MessageReceiveCell(msg: message)
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(.zero)
                    }
                    .listStyle(.plain)
                    MessageInputContentView(store: store)
                })
                .toolbar {
                    ToolbarItem(placement: .topBarLeading, content: {
                        Image(.iconBack)
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                            .onTapGesture {
                                viewStore.send(.dismissPage)
                            }
                    })

                    ToolbarItem(placement: .principal, content: {
                        HStack(alignment: .center, spacing: 0, content: {
                            Text(viewStore.chatConfig.model.title)
                                .font(.custom("DOUYINSANSBOLD-GB", size: 16))

                            Image(.homeIconTriangledown)
                                .scaledToFit()
                                .frame(width: 10, height: 10)
                                .padding(.leading, 10)
                        })
                        .onTapGesture {
                            viewStore.send(.chatModelSetupTapped)
                        }
                    })

                    ToolbarItem(placement: .topBarTrailing, content: {
                        NavigationLink(destination: Text("Destination"), label: {
                            Image(.iconShare)
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                        })
                    })
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .task {
                viewStore.send(.loadChatConfig)
                viewStore.send(.loadLocalMessages)
            }
            .sheet(store: store.scope(state: \.$modelSetup,
                                      action: \.presentationModelSetup)) { store in
                ChatModelSetupView(store: store)
            }
        }
    }
}

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

// MARK: - 消息接收方

/// 消息接收方
struct MessageReceiveCell: View {
    var msg: MessageItemModel
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Image(.homeIconBubble)
                .scaledToFit()
                .frame(width: 30, height: 30)
                .background(Color(hexadecimal6: 0xF77955))
                .cornerRadius(15)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 10))

            ZStack(alignment: .center, content: {
                VStack(alignment: .leading, spacing: 5) {
                    Text(msg.content)
                        .font(.system(size: 14, weight: .regular))
                        .padding(EdgeInsets(top: 14, leading: 14, bottom: 0, trailing: 14))

                    HStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 0, content: {
                        Button(action: {}, label: {
                            Image(.chatIconRefreshBlack)
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding(.all, 6)
                        })

                        Button(action: {}, label: {
                            Image(.chatIconCopyBlack)
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding(.all, 6)
                        })

                        Button(action: {}, label: {
                            Image(.chatIconShareBlack)
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding(.all, 6)
                        })

                        Button(action: {}, label: {
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

// MARK: - 消息发送方

/// 消息发送方
struct MessageSenderCell: View {
    var msg: MessageItemModel
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Spacer()

            ZStack(alignment: .center, content: {
                VStack(alignment: .trailing, spacing: 5) {
                    Text(msg.content)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 14, leading: 14, bottom: 0, trailing: 14))

                    HStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 0, content: {
                        Button(action: {}, label: {
                            Image(.chatIconRefreshWhite)
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding(.all, 6)
                        })

                        Button(action: {}, label: {
                            Image(.chatIconCopyWhite)
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding(.all, 6)
                        })

                        Button(action: {}, label: {
                            Image(.chatIconShareWhite)
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding(.all, 6)
                        })

                        Button(action: {}, label: {
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

            Image(.homeIconBubble)
                .scaledToFit()
                .frame(width: 30, height: 30)
                .background(Color(hexadecimal6: 0xF77955))
                .cornerRadius(15)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
        }
        .padding(.leading, Screen.width * 0.25)
        .padding(.vertical, 10)
    }
}

// MARK: - 消息输入

/// 消息输入
struct MessageInputContentView: View {
    let store: StoreOf<MessageListFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .center, content: {
                VStack(alignment: .center, spacing: 0, content: {
                    HStack(alignment: .center, spacing: 0, content: {
                        if !viewStore.recordState {
                            Button(action: {
                                viewStore.send(.checkSpeechAuth)
                            }, label: {
                                Image(.inputIconSpeaker)
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding(.all, 10)
                            })
                            .buttonStyle(.plain)
                        }

                        MsgTextInputView(text: viewStore.$inputText)
                            .fixedSize(horizontal: false, vertical: true)

                        Button(action: {
                            viewStore.send(.sendMessage)
                        }, label: {
                            Image(.inputIconSend)
                                .scaledToFit()
                                .frame(width: 40, height: 30)
                                .padding(.all, 10)
                        })
                        .buttonStyle(.plain)
                    })
                    .padding(.horizontal, 10)

                    HStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 16, content: {
                        Text("历史")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.black)
                            .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                            .border(Color(hexadecimal6: 0xE9E9E9), width: 1, cornerRadius: 35)

                        Text("诗歌")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.black)
                            .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                            .border(Color(hexadecimal6: 0xE9E9E9), width: 1, cornerRadius: 35)

                        Text("散文")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.black)
                            .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                            .border(Color(hexadecimal6: 0xE9E9E9), width: 1, cornerRadius: 35)

                        Spacer()
                    })
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)

                    if viewStore.recordState {
                        MsgVoiceInputView(store: store)
                    }
                })
            })
            .maxWidth(.infinity)
            .background(Color(hexadecimal6: 0xF6F6F6))
            .cornerRadius(10)
        }
    }

    // 文本输入
    struct MsgTextInputView: View {
        @Binding var text: String
        var maxHeight: CGFloat = 120
        var body: some View {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .padding(6)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .frame(minHeight: 35)
                    .cornerRadius(10)
                    .fixedSize(horizontal: false, vertical: true)

                if text.isEmpty {
                    Text("问点什么吧")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hexadecimal6: 0x999999))
                        .padding(.horizontal, 11)
                        .padding(.vertical, 14)
                }
            }
        }
    }

    // 语音输入
    struct MsgVoiceInputView: View {
        let store: StoreOf<MessageListFeature>
        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Button(action: {
                        store.send(.finishRecord)
                    }, label: {
                        Image(.chatSpeakerIconStop)
                            .scaledToFit()
                            .foregroundColor(.white)
                            .padding(.all, 10)
                            .frame(width: 100, height: 100)
                    })
                    .padding(.vertical, 15)

//                    VStack(alignment:  .center, spacing: 0, content: {
//
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hexadecimal6: 0x027AFF)))
//                            .frame(width: 30, height: 30)
//                            .padding(.bottom, 5)
//
//                        Text("转换中…")
//                            .font(.system(size: 14), weight: .medium)
//                            .foregroundColor(Color(hexadecimal6: 0x027AFF))
//                            .padding(.bottom, 5)
//                    })
                }
            }
            .maxWidth(.infinity)
            .background(Color(hexadecimal6: 0xE8E8E8))
        }
    }
}

// 语音输入

#Preview {
    MessageListView(store: Store(
        initialState: MessageListFeature.State(),
        reducer: { MessageListFeature() }
    ))
}
