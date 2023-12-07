//
//  SegmentedControl.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/27.
//

import SwiftUI

struct SegmentedControlConfiguration {
    var backgroundRadius: CGFloat = 20
    var selectRadius: CGFloat = 18
    var backgroundColor: Color = Color.white
    var selectColor: Color = Color(hex: 0x027AFF)
    var height: CGFloat = 46
    var textColor: Color = Color.black
    var textSelectColor: Color = Color.white
    var textFont: Font = .system(size: 14, weight: .medium)
}

struct SegmentedControl: View {
    
    var configuratiion = SegmentedControlConfiguration()
    var items: [String]
    @Binding var selectedIndex: Int
    @Namespace var namespace
    
    var body: some View {
        ZStack {
            if items.count > 5 {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 0) {
                            ForEach(0..<items.count, id: \.self) { index in
                                Rectangle()
                                    .id(index)
                                    .frame(width: 84)
                                    .foregroundColor(.white.opacity(0.01))
                                    .overlay(content: {
                                        Text(items[index])
                                            .font(configuratiion.textFont)
                                            .foregroundColor(selectedIndex == index ? configuratiion.textSelectColor : configuratiion.textColor)
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(1)
                                            .padding(.horizontal, 5)
                                    })
                                    .matchedGeometryEffect(
                                        id: index,
                                        in: namespace,
                                        isSource: true
                                    )
                                    .onTapGesture {
                                        withAnimation {
                                            selectedIndex = index
                                            if #available(iOS 16.0, *) {
                                                proxy.scrollTo(selectedIndex, anchor: .center)
                                            } else {
                                                proxy.scrollTo(selectedIndex, anchor: .trailing)
                                            }
                                        }
                                    }
                            }
                        }
                        .frame(height: configuratiion.height)
                    }
                    .animation(.default, value: selectedIndex)
                }
            } else {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(0..<items.count, id: \.self) { index in
                        Rectangle()
                            .foregroundColor(.white.opacity(0.01))
                            .overlay(content: {
                                Text(items[index])
                                    .font(configuratiion.textFont)
                                    .foregroundColor(selectedIndex == index ? configuratiion.textSelectColor : configuratiion.textColor)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                    .padding(.horizontal, 5)
                            })
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
            }
        }
        .background {
            Rectangle()
                .fill(configuratiion.selectColor)
                .cornerRadius(configuratiion.selectRadius)
                .matchedGeometryEffect(
                    id: selectedIndex,
                    in: namespace,
                    isSource: false
                )
        }
        .padding(2)
        .frame(height: configuratiion.height)
        .background(configuratiion.backgroundColor)
        .cornerRadius(configuratiion.backgroundRadius)
    }
}
