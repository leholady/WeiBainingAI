//
//  ChatMsgShareView.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/30.
//

import SwiftUI
import SwiftUIX
import ComposableArchitecture

struct ChatMsgShareView: View {
    let store: StoreOf<ChatMsgShareFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { (_: ViewStoreOf<ChatMsgShareFeature>) in
            ZStack(alignment: .center) {
                VStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        Image(.avatarUser)
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .background(Color(hexadecimal6: 0xF77955))
                            .cornerRadius(15)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 10))

                        ZStack(alignment: .center, content: {
                            VStack(alignment: .trailing, spacing: 5) {
                                Text("写一首古代散文诗歌")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.white)
                                    .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                            }
                            .background(Color(hexadecimal6: 0x027AFF))
                            .cornerRadius(20)

                        })
                        Spacer()
                    }
                    .padding(.trailing, Screen.width * 0.25)
                    .padding(.vertical, 10)

                    HStack(alignment: .top, spacing: 0) {
                        Image(.avatarUser)
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .background(Color(hexadecimal6: 0xF77955))
                            .cornerRadius(15)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 10))

                        ZStack(alignment: .center, content: {
                            VStack(alignment: .trailing, spacing: 5) {
                                Text("在昔日的土地上，影子舞动，时间展开古老的恍惚，一个故事展开，很久以前的日子，低声吟唱，将永远持续。在月亮的空灵光芒下，古老的智慧，赋予的秘密，星星的交响曲 点燃黑夜，引导灵魂穿越古老力量的国度。")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.black)
                                    .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                            }
                            .background(Color(hexadecimal6: 0xF6F6F6))
                            .cornerRadius(20)

                        })
                        Spacer()
                    }
                    .padding(.trailing, Screen.width * 0.25)
                    .padding(.vertical, 10)

                    HStack(alignment: .center, spacing: 10, content: {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(hexadecimal6: 0xFCB990))
                            .padding(10)

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
                            .padding(10)
                    })
                }
            }
            .background(Color.clear)
            .cornerRadius(20)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ChatMsgShareView(store: Store(
        initialState: ChatMsgShareFeature.State(),
        reducer: { ChatMsgShareFeature() }
    ))
}
