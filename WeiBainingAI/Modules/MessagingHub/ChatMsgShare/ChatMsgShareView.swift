//
//  ChatMsgShareView.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/30.
//

import ComposableArchitecture
import SwiftUI
import SwiftUIX

struct ChatMsgShareView: View {
    let store: StoreOf<ChatMsgShareFeature>
    // 用 State 来存储每个 item 的高度
    @State private var itemHeights: [CGFloat] = []
    var body: some View {
        WithViewStore(store, observe: { $0 }) { (viewStore: ViewStoreOf<ChatMsgShareFeature>) in
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                ScreenshotTableView(
                    shotting: viewStore.$shouldTakeSnapshot,
                    completed: { screenshot in
                        viewStore.send(.takeSnapshotSucceeded(screenshot))
                    }
                ) {
                    // 实际内容
                    ShareMegCardView(store: store)
                        .cornerRadius(20)
                        .ignoresSafeArea()
                        .padding(.horizontal, 30)
                }
                Spacer()
                SharePlatformItemView(store: store)
            }
            .task {
                viewStore.send(.loadChatShareTopics)
            }
            .popover(isPresented: viewStore.$showSharing) {
                // 显示分享视图
                ActivityView(activityItems: [viewStore.snapshotImage as Any],
                             applicationActivities: nil)
            }
            .background(
                clearBackground(true)
                    .onTapGesture {
                        viewStore.send(.dismissPage)
                    }
            )
        }
    }
}

// 分享预览消息的卡片
struct ShareMegCardView: View {
    let store: StoreOf<ChatMsgShareFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { (viewStore: ViewStoreOf<ChatMsgShareFeature>) in
            ZStack(alignment: .center) {
                VStack(alignment: .center, spacing: 0) {
                    List(viewStore.shareMsgList, id: \.self) { item in
                        ShareMesListPreview(currentMsg: item)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.zero)
                            .listSectionSeparator(.hidden)
                            .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                    .padding(.vertical, 10)
                    .frame(height: 300)

                    HStack(alignment: .center, spacing: 10, content: {
                        Image(.shareIconAppicon)
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .padding(.leading, 20)

                        VStack(alignment: .leading, spacing: 0, content: {
                            Text("ChatMind")
                                .font(.custom("DOUYINSANSBOLD-GB", size: 24))
                                .foregroundColor(.black)

                            Text("此处为副标题")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.black)
                        })

                        Spacer()

                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(hexadecimal6: 0xF77955))
                            .padding(.trailing, 20)
                    })
                    .padding(.vertical, 20)
                    .maxWidth(.infinity)
                    .background(Color(hexadecimal6: 0xF6F6F6))
                }
            }
            .background(.white)
        }
    }
}

// 分享预览消息
struct ShareMesListPreview: View {
    var currentMsg: MessageItemWCDB
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                Image(currentMsg.roleType == .robot ? .chatavatar : .avatarUser)
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .background(Color(hexadecimal6: 0xF77955))
                    .cornerRadius(15)
                    .padding(.trailing, 10)

                ZStack(alignment: .center, content: {
                    VStack(alignment: .trailing, spacing: 5) {
                        Text(currentMsg.content)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(
                                currentMsg.roleType == .robot ? .black : .white
                            )
                            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    }
                    .background(
                        currentMsg.roleType == .robot ? Color(hexadecimal6: 0xF6F6F6) : Color(hexadecimal6: 0x027AFF)
                    )
                    .cornerRadius(20)

                })
                Spacer()
            }
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 30))
    }
}

// 分享平台选择
struct SharePlatformItemView: View {
    let store: StoreOf<ChatMsgShareFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { (viewStore: ViewStoreOf<ChatMsgShareFeature>) in
            ZStack(alignment: .center, content: {
                VStack(alignment: .center, spacing: 0, content: {
                    Divider()
                        .frame(width: 30, height: 4)
                        .background(Color(hexadecimal6: 0xDDDDDD))
                        .cornerRadius(2)
                        .padding(.top, 10)
                        .padding(.bottom, 30)

                    VStack(alignment: .leading, spacing: 0, content: {
                        Button(action: {
                            viewStore.send(.didTakeSnapshot)
                        }, label: {
                            VStack(spacing: 15, content: {
                                Image(.shareIconMore)
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                Text("更多")
                                    .font(.system(size: 10, weight: .regular))
                                    .foregroundColor(Color(hexadecimal6: 0x666666))
                            })
                        })
                        .buttonStyle(.plain)
                    })

                })
            })
            .maxWidth(.infinity)
            .background(Color(hexadecimal6: 0xF6F6F6))
        }
    }
}

#Preview {
    ChatMsgShareView(store: Store(
        initialState: ChatMsgShareFeature.State(),
        reducer: { ChatMsgShareFeature() }
    ))
}
