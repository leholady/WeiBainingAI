//
//  MessagingHubView.swift
//  WeiBainingAI
//
//  Created by MorningStar on 2023/11/24.
//

import ComposableArchitecture
import SwiftUI
import SwiftUIX

struct MessagingHubView: View {
    let store: StoreOf<MessagingHubViewFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView(content: {
                ScrollView {
                    VStack(alignment: .center, spacing: 0, content: {
                        NewQuestionView(store: store)
                            .frame(maxWidth: .infinity)
                            .background(Color(hexadecimal6: 0xF7F7F7))

                        SuggestQuestionListView(store: store)
                            .frame(maxWidth: .infinity)
                            .background(Color(hexadecimal6: 0xF7F7F7))
                            .height(300)

                        TopicHistoryView(store: store)
                            .frame(maxWidth: .infinity)
                            .background(Color(hexadecimal6: 0xF7F7F7))
                    })
                }
                .listStyle(.plain)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading, content: {
                        Text("ChatMind")
                            .font(.custom("DOUYINSANSBOLD-GB", size: 24))
                    })
                    ToolbarItem(placement: .topBarTrailing, content: {
                        HStack(spacing: 10) {
                            Image(.homeIconMember)
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .onTapGesture {}

                            Image(.homeIconHistory)
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .onTapGesture {
                                    viewStore.send(.didTapHistoryMsg)
                                }
                        }
                    })
                }
            })
            .navigationViewStyle(.stack)
            .fullScreenCover(store: store.scope(state: \.$msgItem,
                                                action: \.presentationNewChat)) { store in
                MessageListView(store: store)
            }
            .fullScreenCover(store: store.scope(state: \.$historyItem,
                                                action: \.presentationHistoryMsg)) { store in
                ChatTopicsListView(store: store)
            }
            .task {
                viewStore.send(.loadDefaultData)
            }
        }
    }
}

// MARK: - 发起新提问

/// 发起新提问
struct NewQuestionView: View {
    let store: StoreOf<MessagingHubViewFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 0, content: {
                Image(.homeIconPresentation)
                    .scaledToFit()
                    .padding(.vertical, 20)

                Text("欢迎使用ChatMind，探索超过 \n2700,000 个精彩答案")
                    .font(.system(size: 20, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)

                Button(action: {
                    viewStore.send(.didTapStartNewChat)
                }, label: {
                    Text("开始提问")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(20)
                })
                .buttonStyle(.plain)
                .padding(.top, 30)

                Text("Power by OpenAI ChatGPT")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Color(hexadecimal6: 0x999999))
                    .padding(.top, 10)
            })
            .padding(.horizontal, 20)
            .background(.white)
        }
    }
}

// MARK: - 建议问题列表

/// 建议问题列表
struct SuggestQuestionListView: View {
    let store: StoreOf<MessagingHubViewFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 20, content: {
                VStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 5, content: {
                    Text("建议问题")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("提出复杂的问题以获得更好的答案。")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(hexadecimal6: 0x999999))
                        .frame(maxWidth: .infinity, alignment: .leading)
                })
                .padding(.horizontal, 20)
                .padding(.top, 40)

                List {
                    ForEach(viewStore.suggestions, id: \.self) { suggestion in
                        SuggestQuestionListItemView(suggestion: suggestion)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .listRowSpacing(10)
            })
            .background(.white)
        }
    }

    struct SuggestQuestionListItemView: View {
        var suggestion: SuggestionsModel

        var body: some View {
            HStack {
                Image(.homeIconBubble)
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .padding(.leading, 16)

                Text(suggestion.title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(.iconMore)
                    .scaledToFit()
                    .padding(.horizontal, 22)
            }
            .padding(.vertical, 10)
            .background(Color(hexadecimal6: 0xF6F6F6))
            .cornerRadius(10)
        }
    }
}

// MARK: - 话题历史

/// 话题历史
struct TopicHistoryView: View {
    let store: StoreOf<MessagingHubViewFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 0, content: {
                VStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 5, content: {
                    Text("话题历史")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("您有多个主题，请选择以下主题之一以继续。")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(hexadecimal6: 0x999999))
                        .frame(maxWidth: .infinity, alignment: .leading)
                })
                .padding(.horizontal, 20)
                .padding(.top, 40)

                ScrollView(.horizontal, showsIndicators: false, content: {
                    HStack(spacing: 10, content: {
                        ForEach(viewStore.topicList, id: \.self) { topic in
                            TopicHistoryItemView(topicModel: topic)
                        }
                    })
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                })
                .background(.white)
            })
            .background(.white)
        }
    }

    struct TopicHistoryItemView: View {
        var topicModel: TopicHistoryModel
        var body: some View {
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
                    .frame(maxWidth: Screen.width - 86, alignment: .leading)
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
            .background(Color(hexadecimal6: 0xF6F6F6))
            .cornerRadius(10)
        }
    }
}

#Preview {
    MessagingHubView(store: Store(
        initialState: MessagingHubViewFeature.State(),
        reducer: { MessagingHubViewFeature() }
    ))
}
