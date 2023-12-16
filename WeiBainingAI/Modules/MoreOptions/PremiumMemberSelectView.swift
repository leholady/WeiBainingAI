//
//  PremiumMemberSelectView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/5.
//

import SwiftUI

struct PremiumMemberSelectView: View {
    @Binding var selectPage: Int
    var pageItems: [PremiumMemberPageModel]
    @Binding var itemSelects: [Int]?
    var cellAction: (Int, Int) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if pageItems.count > 1 {
                SegmentedControl(
                    configuratiion: SegmentedControlConfiguration(backgroundRadius: 8,
                                                                  selectRadius: 6,
                                                                  backgroundColor: Color(hex: 0x313136),
                                                                  selectColor: Color(hex: 0x69696F),
                                                                  height: 29,
                                                                  textColor: Color.white),
                    items: pageItems.compactMap { $0.pageState.title },
                    selectedIndex: $selectPage
                )
                .frame(width: 160)
            }
            if pageItems.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .padding(50)
            }
            if !pageItems.isEmpty {
                TabView(selection: $selectPage) {
                    ForEach(0..<pageItems.count, id: \.self) { index in
                        ScrollView {
                            VStack {
                                ForEach(0..<pageItems[index].pageItems.count, id: \.self) { itemIndex in
                                    PremiumMemberSelectItemView(model: pageItems[index].pageItems[itemIndex],
                                                                isSelect: itemSelects?[index] == itemIndex)
                                    .onTapGesture {
                                        cellAction(index, itemIndex)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 270)
            }
        }
        .padding(.vertical, 20)
    }
}
