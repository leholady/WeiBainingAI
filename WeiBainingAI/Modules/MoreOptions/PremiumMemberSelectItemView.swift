//
//  PremiumMemberSelectItemView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/2.
//

import SwiftUI

struct PremiumMemberSelectItemView: View {
    
    var model: PremiumMemberModel
    var isSelect: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(model.title ?? "")
                    .font(.system(size: 16, weight: .semibold))
                HStack(spacing: 0) {
                    Text("\(model.code ?? "")\(model.price ?? "")")
                        .font(.system(size: 18, weight: .semibold))
                    if model.state == .premium {
                        Text("/\(model.unit ?? "")")
                            .font(.system(size: 12, weight: .medium))
                            .offset(y: 1.5)
                    }
                }
            }
            .foregroundColor(.white)
            Spacer()
            Image(isSelect ? "icon_sel" : "icon_unsel")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(isSelect ? Color(hex: 0x027AFF) : Color.white.opacity(0.1))
        .cornerRadius(20)
    }
}
