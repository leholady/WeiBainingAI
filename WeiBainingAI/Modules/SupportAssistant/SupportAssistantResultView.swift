//
//  SupportAssistantResultView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/29.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct SupportAssistantResultView: View {
    
    let store: StoreOf<SupportAssistantResultFeature>
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack(spacing: 30) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .overlay {
                            KFImage(viewStore.imgUrl)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    Button(action: {
                        viewStore.send(.savePhotoAlbum)
                    }, label: {
                        Text("保存到相册")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 300, height: 50)
                            .background(Color(hex: 0x027AFF))
                            .cornerRadius(20)
                    })
                }
                .padding(20)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            viewStore.send(.delegate(.resultDismiss))
                        }, label: {
                            Text("完成")
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .semibold))
                        })
                    }
                }
            }
            .background(.white)
        }
    }
}

#Preview {
    SupportAssistantResultView(store: Store(initialState: SupportAssistantResultFeature.State(imgUrl: URL(string: "\(HttpConst.hostImg)/4cfc6bbdeea1344e8437b15e7904b157")!), reducer: {
        SupportAssistantResultFeature()
    }))
}
