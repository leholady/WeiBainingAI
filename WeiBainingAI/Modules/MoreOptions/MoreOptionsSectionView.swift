//
//  MoreOptionsSectionView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/1.
//

import SwiftUI

struct MoreOptionsSectionView: View {

    var group: MoreOptionsGroupModel
    var balanceItems: [MoreBalanceItemModel]
    var action: (MoreOptionsGroupModel.MoreOptionsItemModel) -> Void
    
    var body: some View {
        Section(content: {
            VStack {
                ForEach(group.items) { item in
                    switch item {
                    case .itemBalance:
                        MoreOptionsBalanceCell(items: balanceItems)
                    default:
                        MoreOptionsItemCell(item: item)
                            .onTapGesture {
                                action(item)
                            }
                    }
                    if item != group.items.last {
                        Divider()
                            .padding(.leading, 20)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(10)
        }, header: {
            Text(group.rawValue)
                .foregroundColor(Color(hex: 0x666666))
                .font(.system(size: 12, weight: .medium))
        })
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}
