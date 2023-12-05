//
//  PremiumMemberView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/2.
//

import SwiftUI
import ComposableArchitecture

struct PremiumMemberView: View {
    
    let store: StoreOf<PremiumMemberFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .topLeading) {
                Image("member_bg")
                    .resizable()
                    .frame(height: 375)
                    .ignoresSafeArea()
                ScrollView(.vertical,
                           showsIndicators: false) {
                    VStack {
                        PremiumMemberHeaderView(items: viewStore.headerItems)
                        PremiumMemberSelectView(selectPage: viewStore.$pageSelect,
                                                pageItems: viewStore.pageItems,
                                                itemSelects: viewStore.$itemSelects) { pageIndex, itemIndex in
                            viewStore.send(.cellDidAt(pageIndex, itemIndex))
                        }
                        memberBottomButtons {
                            viewStore.send(.memberStartBuy)
                        } privateAction: {
                            viewStore.send(.dismissSafari(HttpConst.privateUrl))
                        } usageAction: {
                            viewStore.send(.dismissSafari(HttpConst.usageUrl))
                        } feedbackAction: {
                            viewStore.send(.dismissSafari(HttpConst.feedbackUrl))
                        }
                    }
                }
                .ignoresSafeArea()
                Button(action: {
                    viewStore.send(.premiumDismiss)
                }, label: {
                    Image("icon_back_white")
                        .frame(width: 44, height: 44)
                })
            }
            .onAppear {
                viewStore.send(.uploadPageItems)
            }
            .fullScreenCover(store: self.store.scope(state: \.$safariState,
                                                     action: \.fullScreenCoverSafari)) { store in
                MoreSafariView(store: store)
            }
        }
        .background(.black)
    }
    
    func memberBottomButtons(openAction: @escaping () -> Void,
                             privateAction: @escaping () -> Void,
                             usageAction: @escaping () -> Void,
                             feedbackAction: @escaping() -> Void) -> some View {
        VStack(spacing: 20) {
            Button(action: openAction,
                   label: {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundColor(Color(hex: 0xFF9500))
                    .frame(height: 50)
                    .overlay {
                        Text("继续")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
            })
            HStack {
                Button(action: usageAction,
                       label: {
                    Text("用户协议")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: 0x999999))
                })
                Rectangle()
                    .foregroundColor(Color(hex: 0x999999))
                    .frame(width: 1, height: 10)
                Button(action: privateAction,
                       label: {
                    Text("隐私政策")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: 0x999999))
                })
                Spacer()
                Button(action: feedbackAction,
                       label: {
                    Text("恢复购买")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: 0x999999))
                })
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }
}

#Preview {
    PremiumMemberView(store: Store(initialState: PremiumMemberFeature.State(), reducer: {
        PremiumMemberFeature()
    }))
}
