//
//  SupportAssistantDetailsSegmentedCell.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/28.
//

import SwiftUI

struct SupportAssistantDetailsSegmentedCell: View {
    var title: String
    var items: [String]
    @Binding var select: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: 0x666666))
            SegmentedControl(items: items, selectedIndex: $select)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 5,
                                  leading: 20,
                                  bottom: 25,
                                  trailing: 20))
    }
}
