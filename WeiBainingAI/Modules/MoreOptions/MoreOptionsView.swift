//
//  MoreOptionsView.swift
//  WeiBainingAI
//
//  Created by MorningStar on 2023/11/24.
//

import SwiftUI
import ComposableArchitecture

struct MoreOptionsView: View {
    let store: StoreOf<MoreOptionsFeature>
    var body: some View {
        NavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack(spacing: 20) {
                    List {
                        MoreOptionsHeaderView()
                            .onTapGesture {
                                viewStore.send(.dismissPremium)
                            }
                        ForEach(viewStore.groups) { group in
                            MoreOptionsSectionView(group: group,
                                                   balanceItems: viewStore.balanceItems) {
                                switch $0 {
                                case .itemMember:
                                    viewStore.send(.dismissPremium)
                                case .itemPolicy:
                                    viewStore.send(.dismissSafari(HttpConst.privateUrl))
                                case .itemAgreement:
                                    viewStore.send(.dismissSafari(HttpConst.usageUrl))
                                case .itemConnect:
                                    viewStore.send(.dismissSafari(HttpConst.feedbackUrl))
                                default:
                                    break
                                }
                            }
                        }
                    }
                    .background(Color.clear)
                    .listStyle(.plain)
                    Text("v 1.0")
                        .foregroundColor(Color(hex: 0x999999))
                        .font(.system(size: 10))
                }
                .padding(.bottom, 30)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("更多")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                .onAppear {
                    viewStore.send(.uploadBalanceItems)
                }
                .fullScreenCover(store: self.store.scope(state: \.$premiumState,
                                                         action: \.fullScreenCoverPremium)) { store in
                    PremiumMemberView(store: store)
                }
                .fullScreenCover(store: self.store.scope(state: \.$safariState,
                                                         action: \.fullScreenCoverSafari)) { store in
                    MoreSafariView(store: store)
                }
             }
            .background(Color(hex: 0xF6F6F6))
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    MoreOptionsView(store: Store(
        initialState: MoreOptionsFeature.State(),
        reducer: { MoreOptionsFeature() }
    ))
}
