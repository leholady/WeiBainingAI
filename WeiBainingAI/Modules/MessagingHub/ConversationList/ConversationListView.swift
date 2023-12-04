//
//  HistoryChatTopicsView.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/2.
//

import ComposableArchitecture
import SwiftUI

struct ConversationListView: View {
    let store: StoreOf<ConversationListFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { (viewStore: ViewStoreOf<ConversationListFeature>) in
            NavigationView(content: {
                VStack(alignment: .center, spacing: 0, content: {
                    if viewStore.conversationList.isEmpty {
                        ConversationEmptyView()
                    } else {
                        List {
                            ForEach(viewStore.conversationList, id: \.identifier) { topic in
                                ConversationItemView(topicModel: topic,
                                                     isEditing: viewStore.$isEditing)
                                    .onTapGesture {
                                        viewStore.send(.didSelectConversation(topic))
                                    }
                            }
                            .listRowSeparator(.hidden)
                            .listSectionSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        }
                        .listStyle(.plain)
                        .listRowSpacing(10)
                    }

                    // 编辑悬浮按钮
                    if viewStore.isEditing == true {
                        ConversationEditModeView(store: store)
                    }
                })
                .background(Color(hexadecimal6: 0xF6F6F6))
                .toolbar(content: {
                    ToolbarItem(placement: .principal, content: {
                        Text("历史话题")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    })

                    ToolbarItem(placement: .topBarLeading, content: {
                        Button(action: {
                            viewStore.send(.dismissTopics)
                        }, label: {
                            Image(.iconCancel)
                                .scaledToFit()
                        })
                    })

                    ToolbarItem(placement: .topBarTrailing, content: {
                        Button(action: {
                            viewStore.send(.didSelectEdit)
                        }, label: {
                            Text(viewStore.isEditing ? "完成" : "编辑")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hexadecimal6: 0x007AFF))
                        })
                        .buttonStyle(.plain)
                    })
                })
            })
            .fullScreenCover(store: store.scope(state: \.$chatPage,
                                                action: \.presentationNewChat)) { store in
                MessageListView(store: store)
            }
            .task {
                viewStore.send(.loadChatTopics)
            }
        }
    }
}

/// 话题历史单项
struct ConversationItemView: View {
    var topicModel: ConversationItemWCDB
    @Binding var isEditing: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            if isEditing {
                Image(topicModel.isSelected ? .iconSel : .iconUnsel)
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .padding(.leading, 16)
            }

            VStack(alignment: .leading, spacing: 0, content: {
                HStack(alignment: .center, spacing: 9, content: {
                    Image(.homeIconBubble)
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .background(Color(hexadecimal6: 0xF77955))
                        .cornerRadius(13)

                    VStack(alignment: .leading, spacing: 0, content: {
                        Text("ChatMind")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hexadecimal6: 0x888888))
                            .frame(alignment: .leading)

                        Text(topicModel.timestamp.timeFormat)
                            .font(.custom("DOUYINSANSBOLD-GB", size: 9))
                            .foregroundColor(Color(hexadecimal6: 0x999999))
                            .frame(alignment: .leading)

                    })
                })
                .padding(.horizontal, 16)

                Text(topicModel.reply)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    .lineLimit(3)

                Divider()
                    .height(0.5)
                    .background(Color.black.opacity(0.05))
                    .padding(.horizontal, 16)

                HStack(alignment: .center, spacing: 9, content: {
                    Image(.homeIconBubble)
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .background(Color(hexadecimal6: 0x027AFF))
                        .cornerRadius(13)

                    VStack(alignment: .leading, spacing: 0, content: {
                        Text("你")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hexadecimal6: 0x888888))
                            .frame(alignment: .leading)

                        Text(topicModel.topic)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hexadecimal6: 0xBBBBBB))
                            .frame(alignment: .leading)
                            .lineLimit(3)
                    })
                })
                .padding(EdgeInsets(top: 10, leading: 16, bottom: 0, trailing: 16))
            })
            .padding(.vertical, 10)
        }
        .background(Color(hexadecimal6: 0xFFFFFF))
        .cornerRadius(10)
    }
}

/// 空白视图
struct ConversationEmptyView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(.historyDefault)
                .scaledToFit()
                .frame(width: 220, height: 90)
                .padding(.bottom, 10)

            Text("还没有聊天记录")
                .font(.system(size: 14))
                .foregroundColor(Color(hexadecimal6: 0x666666))

            Button(action: /*@START_MENU_TOKEN@*/ {}/*@END_MENU_TOKEN@*/, label: {
                RoundedRectangle(cornerRadius: 20)
                    .frame(height: 50)
                    .foregroundColor(Color(hexadecimal6: 0x027AFF))
                    .overlay {
                        Text("开始新对话")
                            .font(.system(size: 16), weight: .semibold)
                            .foregroundColor(.white)
                    }
            })
            .buttonStyle(.plain)
            .padding(.horizontal, 40)
            .padding(.top, 65)

            VStack(alignment: .center, spacing: 0) {
                Text("New Chat With Chat GPT4")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hexadecimal6: 0x027AFF))
                    .padding(.top, 20)
                Divider()
                    .frame(width: 150, height: 1)
                    .background(Color(hexadecimal6: 0x027AFF))
                    .padding(.top, -2)
            }
        }
    }
}

/// 消息cell
struct HistoryChatTopicsCell: View {
    var body: some View {
        Text("HistoryChatTopicsCell")
    }
}

/// 编辑模式
struct ConversationEditModeView: View {
    let store: StoreOf<ConversationListFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { (viewStore: ViewStoreOf<ConversationListFeature>) in
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 52)
                .overlay {
                    HStack(alignment: .center, spacing: 0, content: {
                        Button(action: {
                            viewStore.send(.didSelectAllConversation)
                        }, label: {
                            HStack(alignment: .center, spacing: 5, content: {
                                Image(viewStore.isAllSelected ? .iconSel : .iconUnsel)
                                    .scaledToFit()
                                    .frame(width: 26, height: 26)

                                Text(viewStore.isAllSelected ? "取消全选" : "全选")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hexadecimal6: 0x007AFF))
                            })
                        })
                        .buttonStyle(.plain)

                        Spacer()

                        Button(action: {
                            viewStore.send(.didTapDeleteConversation)
                        }, label: {
                            RoundedRectangle(cornerRadius: 15)
                                .frame(width: 65, height: 32)
                                .foregroundColor(Color(hexadecimal6: 0x007AFF))
                                .overlay {
                                    Text("删除")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                        })
                        .buttonStyle(.plain)
                    })
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, 16)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ConversationListView(store: Store(
        initialState: ConversationListFeature.State(userConfig: UserProfileModel(userId: "")),
        reducer: { ConversationListFeature() }
    ))
}
