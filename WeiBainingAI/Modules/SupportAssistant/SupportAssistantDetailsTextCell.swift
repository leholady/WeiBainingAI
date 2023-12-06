//
//  SupportAssistantDetailsTextCell.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/28.
//

import SwiftUI

struct SupportAssistantDetailsTextCell: View {
    
    var title: String
    var placeholder: String
    @Binding var text: String
    var editorHeight: CGFloat = 120
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: 0x666666))
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .padding(6)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .frame(minHeight: editorHeight)
                    .background(.white)
                    .cornerRadius(10)
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: 0x999999))
                        .padding(.horizontal, 11)
                        .padding(.vertical, 14)
                }
            }
            .padding(.bottom, 25)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 5,
                                  leading: 20,
                                  bottom: 0,
                                  trailing: 20))
    }
}
