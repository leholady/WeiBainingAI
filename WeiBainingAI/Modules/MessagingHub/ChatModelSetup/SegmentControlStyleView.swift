//
//  StyleSegmentControll.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/30.
//

import SwiftUI

struct SegmentControlStyleView: View {
    var items: [String]
    @Binding var selectedIndex: Int
    @Namespace var namespace

    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0 ..< items.count, id: \.self) { index in
                Rectangle()
                    .foregroundColor(.clear)
                    .overlay(content: {
                        VStack(alignment: .center, spacing: 0) {
                            Text(items[index])
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedIndex == index ? Color.white : Color.black)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)

                            Image(selectedIndex == index ? .homeIconTriangleupSel : .homeIconTriangleupUnsel)
                                .scaledToFit()
                                .padding(.top, 8)
                        }
                    })
                    .padding(.horizontal, 5)
                    .matchedGeometryEffect(
                        id: index,
                        in: namespace,
                        isSource: true
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
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
        .frame(height: 60)
        .background(Color.white)
        .cornerRadius(18)
    }
}

#Preview {
    SegmentControlStyleView(items: ["创造力", "平衡", "精确"],
                            selectedIndex: .constant(0))
}
