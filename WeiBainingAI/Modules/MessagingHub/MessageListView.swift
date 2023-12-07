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
        WithViewStore(store, observe: { $0 }) { (viewStore: ViewStoreOf<MessageListFeature>) in
            ZStack(content: {
                NavigationView {
                    VStack(alignment: .center, content: {
                        ScrollView {
                            ScrollViewReader { scrollViewProxy in
                                VStack(alignment: .center, spacing: 0) {
                                    ForEachStore(
                                        self.store.scope(state: \.msgTodos, action: \.actionTodos)
                                    ) { todoStore in
                                        MessageListCellView(store: todoStore)
                                    }
                                    HStack(alignment: .center, spacing: 0, content: {
                                        Spacer()
                                            .frame(width: 0, height: 0, alignment: .center)
                                            .id("scrollToBottom")
                                    })
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            scrollViewProxy.scrollTo("scrollToBottom", anchor: .bottom)
                                        }
                                    }
                                    .onReceive(viewStore.keyboardWillShowPublisher) { _ in
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            scrollViewProxy.scrollTo("scrollToBottom", anchor: .bottom)
                                        }
                                    }
                                    .onReceive(viewStore.msgListPublisher) { _ in
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            scrollViewProxy.scrollTo("scrollToBottom", anchor: .bottom)
                                        }
                                    }
                                }
                            }
                        }

                        MessageInputContentView(store: store)
                    })
                    .onTapGesture(perform: {
                        UIApplication.shared.endEditing()
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
                            Image(.iconShare)
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .onTapGesture {
                                    viewStore.send(.msgShareTapped(nil))
                                }
                        })
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(.stack)

                IfLetStore(
                    store.scope(state: \.$sharePage, action: \.presentationMsgShare)
                ) { store in
                    withAnimation {
                        ChatMsgShareView(store: store)
                            .edgesIgnoringSafeArea(.top)
                    }
                }
            })
            .task {
                viewStore.send(.loadChatConfig)
            }
            .sheet(store: store.scope(state: \.$setupPage,
                                      action: \.presentationModelSetup)) { store in
                ChatModelSetupView(store: store)
            }
        }
    }
}

// MARK: - 消息输入

/// 消息输入
struct MessageInputContentView: View {
    let store: StoreOf<MessageListFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { (viewStore: ViewStoreOf<MessageListFeature>) in
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
                            viewStore.send(.loadConversation)
                        }, label: {
                            Image(.inputIconSend)
                                .scaledToFit()
                                .frame(width: 40, height: 30)
                                .padding(.all, 10)
                        })
                        .buttonStyle(.plain)
                        .disabled(viewStore.inputText.isEmpty)
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
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
        }
    }

    // 文本输入
    struct MsgTextInputView: View {
        @Binding var text: String
        var maxHeight: CGFloat = 120
        var body: some View {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .frame(minHeight: 35)
                    .cornerRadius(10)
                    .padding(6)
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
                        store.send(.changeRecordState(false))
                    }, label: {
                        Image(.chatSpeakerIconStop)
                            .scaledToFit()
                            .foregroundColor(.white)
                            .padding(.all, 10)
                            .frame(width: 100, height: 100)
                    })
                    .padding(.vertical, 15)
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
