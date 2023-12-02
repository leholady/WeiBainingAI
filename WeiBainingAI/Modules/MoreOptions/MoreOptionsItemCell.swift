//
//  MoreOptionsItemCell.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/1.
//

import SwiftUI

struct MoreOptionsItemCell: View {
    var item: MoreOptionsGroupModel.MoreOptionsItemModel
    
    var body: some View {
        HStack {
            Image(item.imageName)
                .resizable()
                .frame(width: 20, height: 20)
            Text(item.rawValue)
                .font(.system(size: 14))
            Spacer()
            Image("icon_more")
                .resizable()
                .frame(width: 14, height: 14)
        }
        .listRowSeparator(.visible)
        .padding(.horizontal, 20)
        .frame(height: 60)
        .background(.white)
    }
}

#Preview {
    MoreOptionsItemCell(item: .itemChat)
}
