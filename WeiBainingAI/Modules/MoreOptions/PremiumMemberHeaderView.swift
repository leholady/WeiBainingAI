//
//  PremiumMemberHeaderView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/2.
//

import SwiftUI

struct PremiumMemberHeaderView: View {
    
    var items: [MemberHeaderItemModel]
    
    var body: some View {
        VStack(spacing: 25) {
            Image("more_membercard_title")
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
