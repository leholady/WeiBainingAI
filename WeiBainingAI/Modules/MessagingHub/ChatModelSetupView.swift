//
//  ChatModelSetupView.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/30.
//

import CompactSlider
import ComposableArchitecture
import SwiftUI

struct ChatModelSetupView: View {
    let store: StoreOf<ChatModelSetupFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { (viewStore: ViewStoreOf<ChatModelSetupFeature>) in
            VStack(alignment: .center, spacing: 0, content: {
                Divider()
                    .frame(width: 30, height: 3)
                    .background(Color(hexadecimal6: 0xDDDDDD))
                    .cornerRadius(2)
                    .padding(.top, 10)

                Text("偏好设置")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hexadecimal6: 0x333333))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical, 20)
                    .padding(.leading, 20)

                ScrollView {
                    VStack(alignment: .center, spacing: 0, content: {
                        ChatModelSelectionView(store: store)
                        ChatStyleSelectionView(store: store)
                        ChatTokenSelectionView(store: store)
                    })
                }

                Button(action: {
                    viewStore.send(.dismissConfig)
                }, label: {
                    Text("完成")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hexadecimal6: 0x007AFF))
                        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
                        .background(Color.white)
                        .cornerRadius(25)
                        .padding(.horizontal, 40)
                })
                .shadow(color: Color(hexadecimal6: 0xE8E8E8),
                        radius: 0, x: 0, y: 2)

            })
            .background(Color(hexadecimal6: 0xF6F6F6))
            .task {
                viewStore.send(.loadChatConfig)
            }
        }
    }
}

// MARK: - 聊天模型选择

struct ChatModelSelectionView: View {
    let store: StoreOf<ChatModelSetupFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { (viewStore: ViewStoreOf<ChatModelSetupFeature>) in
            VStack(alignment: .center, spacing: 0, content: {
                Text("聊天模型")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hexadecimal6: 0x666666))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 10)

                HStack(alignment: .center, spacing: 20, content: {
                    ForEach(0 ..< viewStore.chatModelList.count) { index in
                        ChatModelSelectionItem(
                            isSelect: viewStore.chatConfig.model == viewStore.chatModelList[index],
                            modelItem: viewStore.chatModelList[index]
                        )
                        .onTapGesture {
                            viewStore.send(.selectChatModel(index: viewStore.chatModelList[index]))
                        }
                    }
                })

            })
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }

    struct ChatModelSelectionItem: View {
        var isSelect: Bool
        var modelItem: ChatModelType

        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(isSelect ? Color(hexadecimal6: 0x007AFF) : Color.white)

                VStack(alignment: .leading, spacing: 0, content: {
                    HStack(alignment: .center, spacing: 0, content: {
                        Text(modelItem.title)
                            .font(.custom("DOUYINSANSBOLD-GB", size: 14))
                            .foregroundColor(isSelect ? .white : .black)

                        Spacer()

                        if isSelect {
                            Image(.preferenceIconSel)
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        }

                    })
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))

                    Text(modelItem.desc)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(isSelect ? .white : Color(hexadecimal6: 0x666666))
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
                })
            }
        }
    }
}

// MARK: - 聊天风格选择

struct ChatStyleSelectionView: View {
    let store: StoreOf<ChatModelSetupFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { (viewStore: ViewStoreOf<ChatModelSetupFeature>) in
            VStack(alignment: .leading, spacing: 0) {
                Text("聊天风格")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hexadecimal6: 0x666666))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 10)

                SegmentControlStyleView(items: viewStore.chatStyleList,
                                        selectedIndex: viewStore.$selectStyle)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}

// MARK: - 聊天Token调整

struct ChatTokenSelectionView: View {
    let store: StoreOf<ChatModelSetupFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { (viewStore: ViewStoreOf<ChatModelSetupFeature>) in
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .center, spacing: 10, content: {
                        Text("附加消息计数")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hexadecimal6: 0x666666))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)

                        Text("每个请求附加的已发送消息数")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color(hexadecimal6: 0x666666))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)

                        ZStack(alignment: .center, content: {
                            VerticalSliderView(value: .constant(Float(viewStore.chatConfig.msgCount)),
                                               inRange: 0 ... 10,
                                               fillColor: .blue,
                                               emptyColor: .white,
                                               width: 64,
                                               onEditingChanged: { value in
                                                   viewStore.send(.updateMsgCount(value))
                                               })
                                               .height(150)
                        })
                        .padding(.top, 10)
                        .cornerRadius(20)

                        Text(String(format: "%ld", viewStore.msgCount))
                            .font(.custom("DOUYINSANSBOLD-GB", size: 14))
                            .foregroundColor(.black)

                        Text("GPT4通过尽可能不使用附加消息，显着减少了Token的浪费")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(Color(hexadecimal6: 0x007AFF))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    })

                    VStack(alignment: .center, spacing: 10, content: {
                        Text("最大Token")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hexadecimal6: 0x666666))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)

                        Text("输入令牌和生成令牌的最大长度")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color(hexadecimal6: 0x666666))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)

                        ZStack(alignment: .center, content: {
                            VerticalSliderView(value: .constant(Float(viewStore.chatConfig.maxtokens)),
                                               inRange: 100 ... 4000,
                                               fillColor: .blue,
                                               emptyColor: .white,
                                               width: 64,
                                               onEditingChanged: { value in
                                                   viewStore.send(.updateMsgTokens(value))
                                               })
                                               .height(150)

                        })
                        .padding(.top, 10)
                        .cornerRadius(20)

                        Text(String(format: "%ld", viewStore.msgTokens))
                            .font(.custom("DOUYINSANSBOLD-GB", size: 14))
                            .foregroundColor(.black)
                    })
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    ChatModelSetupView(store: Store(initialState: ChatModelSetupFeature.State(chatConfig: ChatRequestConfigMacro.defaultConfig()), reducer: {
        ChatModelSetupFeature()
    }))
}
