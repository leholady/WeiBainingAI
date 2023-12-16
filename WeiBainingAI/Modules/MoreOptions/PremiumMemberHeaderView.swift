//
//  PremiumMemberHeaderView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/2.
//

import SwiftUI

struct PremiumMemberHeaderView: View {
    
    var items: [MemberHeaderItemModel]
    var title: String
    
    var body: some View {
        VStack(spacing: 25) {
            Text(title)
                .font(.system(size: 30, weight: .semibold))
                .foregroundLinearGradient(Gradient(colors: [Color(hex: 0xFCE4E5),
                                                            Color(hex: 0xF5FEE7),
                                                            Color(hex: 0xE6FFFC),
                                                            Color(hex: 0xF9E3EE)]))
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 2),
                                GridItem(.flexible(), spacing: 2),
                                GridItem(.flexible(), spacing: 2)],
                      spacing: 2,
                      content: {
                ForEach(items) { item in
                    VStack(spacing: 10) {
                        Image(item.imageName)
                        Text(item.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 15)
                }
            })
        }
        .padding(.bottom, 5)
        .padding(.top, 104)
    }
}
