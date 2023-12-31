//
//  SupportAssistantCell.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/27.
//

import SwiftUI
import Kingfisher

struct SupportAssistantCell: View {
    
    let model: SupportAssistantModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            KFAnimatedImage(URL(string: "\(HttpConst.hostImg)/\(model.imgSign)")!)
                .configure({ view in
                    view.framePreloadCount = 3
                })
                .frame(width: 100, height: 100)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(model.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .frame(width: 14, height: 14)
                }
                Text(model.content)
                    .font(.system(size: 12))
                    .foregroundColor(.black.opacity(0.5))
                    .lineSpacing(6)
            }
            .offset(y: 10)
            .padding(.zero)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(10)
    }
}

#Preview {
    SupportAssistantCell(model: SupportAssistantModel(imgSign: "e3436025a39a154abd8a0a2e8f8f2467",
                                                      title: "AI艺术头像制作",
                                                      content: "头像生成器应用程序可让您通过上传图像和自定义不同的样式来创建独特的头像。",
                                                      type: .textToAvatar))
}
