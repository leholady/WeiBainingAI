//
//  GradientProgressView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/29.
//

import SwiftUI

struct GradientProgressView: View {
    var progress: CGFloat
    var gradient: Gradient
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(Color(hex: 0xEBEBEB))
                    .frame(width: geometry.size.width, height: 10)
                RoundedRectangle(cornerRadius: 5)
                    .fill(LinearGradient(gradient: gradient,
                                         startPoint: .leading,
                                         endPoint: .trailing))
                    .frame(width: min(progress * geometry.size.width, geometry.size.width),
                           height: 10)
            }
        }
    }
}

#Preview {
    GradientProgressView(progress: CGFloat(0.1),
                         gradient: Gradient(colors: [Color(hex: 0xFCB990), Color(hex: 0xF77955)]))
}
