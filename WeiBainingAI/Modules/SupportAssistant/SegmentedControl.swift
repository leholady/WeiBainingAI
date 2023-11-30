//
//  SegmentedControl.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/27.
//

import SwiftUI

struct SegmentedControl: View {
    var items: [String]
    @Binding var selectedIndex: Int
    @Namespace var namespace
    
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<items.count, id: \.self) { index in
                Rectangle()
                    .foregroundColor(.clear)
                    .overlay(content: {
                        Text(items[index])
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedIndex == index ? Color.white : Color.black)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    })
                    .padding(.horizontal, 5)
                    .matchedGeometryEffect(
                        id: index,
                        in: namespace,
                        isSource: true
                    )
                    .onTapGesture {
                        withAnimation {
                            selectedIndex = index
                        }
                    }
            }
        }
        .background {
            Rectangle()
                .fill(Color(hex: 0x027AFF))
                .cornerRadius(18)
                .matchedGeometryEffect(
                    id: selectedIndex,
                    in: namespace,
                    isSource: false
                )
        }
        .padding(2)
        .frame(height: 46)
        .background(Color.white)
        .cornerRadius(20)
    }
}
