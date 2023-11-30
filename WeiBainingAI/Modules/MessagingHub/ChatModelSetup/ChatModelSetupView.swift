//
//  ChatModelSetupView.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/30.
//

import SwiftUI

struct ChatModelSetupView: View {
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 0, content: {
            Divider()
                .frame(width: 30, height: 3)
                .background(Color(hexadecimal6: 0xDDDDDD))
                .cornerRadius(2)

            Text("偏好设置")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hexadecimal6: 0x333333))
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.vertical, 20)
                .padding(.leading, 20)

            ChatModelSelectionView()

            ChatModelSelectionView()

        })
        .background(Color(hexadecimal6: 0xF6F6F6))
    }
}

// MARK: - 聊天模型选择

struct ChatModelSelectionView: View {
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 0, content: {
            Text("聊天模型")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hexadecimal6: 0x666666))
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 10)

            HStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 20, content: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color(hexadecimal6: 0x027AFF))

                    VStack(alignment: .center, spacing: 0, content: {
                        HStack(alignment: .center, spacing: 0, content: {
                            Text("GPT-3.5 Turbo")
                                .font(.custom("DOUYINSANSBOLD-GB", size: 14))
                                .foregroundColor(.white)

                            Spacer()

                            Image(.preferenceIconSel)
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        })
                        .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))

                        Text("Turbo 针对对话进行了优化Turbo 针对对话进行了优化Turbo 针对对话进行了优化Turbo 针对对话进行了优化Turbo 针对对话进行了优化")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
                    })
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color(hexadecimal6: 0xFFFFFF))

                    VStack(alignment: .center, spacing: 0, content: {
                        HStack(alignment: .center, spacing: 0, content: {
                            Text("GPT 4")
                                .font(.custom("DOUYINSANSBOLD-GB", size: 14))
                                .foregroundColor(.black)

                            Spacer()

                            Image(.preferenceIconSel)
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        })
                        .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))

                        Text("GPT-4可以遵循复杂的指令并准确地解决难题。GPT-4可以遵循复杂的指令并准确地解决难题。GPT-4可以遵循复杂的指令并准确地解决难题。")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(Color(hexadecimal6: 0x666666))
                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
                    })
                }
            })
        })
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}

// MARK: - 聊天风格


#Preview {
    ChatModelSetupView()
}
