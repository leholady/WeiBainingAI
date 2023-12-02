//
//  ChatModelSetupView.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/30.
//

import ComposableArchitecture
import SwiftUI

struct ChatModelSetupView: View {
    let store: StoreOf<ChatModelSetupFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
                        ChatTokenSelectionView()
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
        }
    }
}

// MARK: - 聊天模型选择

struct ChatModelSelectionView: View {
    let store: StoreOf<ChatModelSetupFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .center, spacing: 0, content: {
                Text("聊天模型")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hexadecimal6: 0x666666))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 10)

                HStack(alignment: .center, spacing: 20, content: {
                    ForEach(viewStore.chatModelList, id: \.self) { model in
                        ChatModelSelectionItem(isSelect: viewStore.selectModelId == model.id,
                                               modelItem: model)
                            .onTapGesture {
                                viewStore.send(.selectChatModel(index: model.id))
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
        var modelItem: ChatModelConfig

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
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                Text("聊天风格")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hexadecimal6: 0x666666))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 10)

                SegmentControlStyleView(items: viewStore.chatStyleItem.compactMap { $0.title },
                                        selectedIndex: viewStore.$selectStyleIndex)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}

// MARK: - 聊天Token调整

struct ChatTokenSelectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 10, content: {
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

                    ZStack(alignment: .bottom, content: {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 64, height: 150, alignment: .center)
                            .foregroundColor(Color(hexadecimal6: 0xFFFFFF))

                        Rectangle()
                            .frame(width: 64, height: 20, alignment: .center)
                            .foregroundColor(Color(hexadecimal6: 0x027AFF))
                    })
                    .padding(.top, 10)
                    .cornerRadius(20)

                    Text("2")
                        .font(.custom("DOUYINSANSBOLD-GB", size: 14))
                        .foregroundColor(.black)

                    Text("GPT4通过尽可能不使用附加消息，显着减少了Token的浪费")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(Color(hexadecimal6: 0x007AFF))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                })

                VStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 10, content: {
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

                    ZStack(alignment: .bottom, content: {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 64, height: 150, alignment: .center)
                            .foregroundColor(Color(hexadecimal6: 0xFFFFFF))

                        Rectangle()
                            .frame(width: 64, height: 100, alignment: .center)
                            .foregroundColor(Color(hexadecimal6: 0x027AFF))
                    })
                    .padding(.top, 10)
                    .cornerRadius(20)

                    Text("2000")
                        .font(.custom("DOUYINSANSBOLD-GB", size: 14))
                        .foregroundColor(.black)
                })
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}

#Preview {
    ChatModelSetupView(store: Store(initialState: ChatModelSetupFeature.State(), reducer: {
        ChatModelSetupFeature()
    }))
}
