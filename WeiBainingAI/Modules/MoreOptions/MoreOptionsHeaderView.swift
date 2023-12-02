//
//  MoreOptionsHeaderView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/1.
//

import SwiftUI

struct MoreOptionsHeaderView: View {
    
    let colors = [Color(hex: 0xFCE4E5),
                  Color(hex: 0xF5FEE7),
                  Color(hex: 0xE6FFFC),
                  Color(hex: 0xF9E3EE)]
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 20) {
                Image("more_membercard_title")
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        moreHeaderItem(text: "无限聊天GPT3.5")
                        moreHeaderItem(text: "解锁GPT4.0和Midjourney")
                        moreHeaderItem(text: "删除所有广告")
                    }
                    Spacer()
                    Text("去升级")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 68, height: 36)
                        .background(Image("more_membercard_btn"))
                }
            }
            .font(.system(size: 11))
            .foregroundColor(.white)
            .padding(20)
            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: 0x425CDA),
                                                                               Color(hex: 0x1A2A7D)]),
                                                   startPoint: .leading,
                                                   endPoint: .trailing))
            .cornerRadius(10)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 20,
                                  leading: 20,
                                  bottom: 0,
                                  trailing: 20))
        .listRowBackground(Color.clear)
    }
    
    func moreHeaderItem(text: String) -> some View {
        HStack {
            Image("more_membercard_icon_star")
            Text(text)
        }
    }
}

#Preview {
    MoreOptionsHeaderView()
}
