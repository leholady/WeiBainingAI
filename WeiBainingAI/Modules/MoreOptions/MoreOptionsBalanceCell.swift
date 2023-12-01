//
//  MoreOptionsBalanceCell.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/1.
//

import SwiftUI

struct MoreOptionsBalanceCell: View {
    
    var items: [MoreBalanceItemModel]
    
    var body: some View {
        HStack {
            ForEach(items) { item in
                Rectangle()
                    .foregroundColor(.clear)
                    .overlay {
                        moreBalanceItem(title: item.title,
                                        number: item.number,
                                        unit: item.unit)
                    }
            }
        }
        .frame(height: 88)
        .background(.white)
    }
    
    func moreBalanceItem(title: String,
                         number: String,
                         unit: String) -> some View {
                    VStack(spacing: 10) {
                        HStack(spacing: 4) {
                            Text(number)
                                 .font(.custom("DOUYINSANSBOLD-GB", size: 14))
                                 .foregroundColor(Color(hex: 0x027AFF))
                            if !unit.isEmpty {
                                Text(unit)
                                     .font(.system(size: 10))
                                     .foregroundColor(Color(hex: 0x888888))
                            }
                        }
                        .padding(6)
                        .background(Color(hex: 0xF6F6F6))
                        .cornerRadius(2)
                       Text(title)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: 0x888888))
                    }
    }
}

#Preview {
    MoreOptionsBalanceCell(items: [MoreBalanceItemModel(title: "ChatGPT 3.5",
                                                        number: "Unlimited",
                                                        unit: ""),
                                   MoreBalanceItemModel(title: "ChatGPT 4.0",
                                                        number: "10.1w",
                                                        unit: "Tokens"),
                                   MoreBalanceItemModel(title: "Midjourney",
                                                        number: "65",
                                                        unit: "Images")])
}
