//
//  SupportAssistantDetailsImageCell.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/28.
//

import SwiftUI

struct SupportAssistantDetailsImageCell: View {
    
    var title: String
    var imageData: Data?
    var addAction: () -> Void
    var deleteAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: 0x666666))
            if let data = imageData {
                ZStack(alignment: .topTrailing) {
                    Image(data: data)?
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                        .padding(10)
                        .onTapGesture {
                            addAction()
                        }
                    Image("img_btn_icon_delete_red")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            deleteAction()
                        }
                }
            }
            if imageData == nil {
                ZStack(alignment: .topTrailing) {
                    Image("assistant_icon_picture")
                        .onTapGesture {
                            addAction()
                        }
                }
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 5,
                                  leading: 20,
                                  bottom: 25,
                                  trailing: 20))
    }
}

#Preview {
    SupportAssistantDetailsImageCell(title: "图像提示",
                                     imageData: nil) {
    
    } deleteAction: {
        
    }
}
