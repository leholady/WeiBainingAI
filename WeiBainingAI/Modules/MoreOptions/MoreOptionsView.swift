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
                        MoreOptionsHeaderView(isVip: viewStore.isVipState)
                            .onTapGesture {
                                viewStore.send(.dismissPremium)
                            }
                        ForEach(viewStore.groups) { group in
                            MoreOptionsSectionView(group: group,
                                                   balanceItems: viewStore.balanceItems) {
                                switch $0 {
                                case .itemMember:
                                    viewStore.send(.dismissPremium)
                                case .itemResume:
                                    viewStore.send(.recover)
                                case .itemChat:
                                    viewStore.send(.didTapHistoryMsg)
                                case .itemPolicy:
                                    viewStore.send(.dismissSafari(HttpConst.privateUrl))
                                case .itemAgreement:
                                    viewStore.send(.dismissSafari(HttpConst.usageUrl))
                                case .itemConnect:
                                    viewStore.send(.dismissSafari(HttpConst.feedbackUrl))
                                case .itemShare:
                                    viewStore.send(.uploadShare)
                                default:
                                    break
                                }
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .background(Color.clear)
                    .listStyle(.plain)
                    Text(viewStore.versionText)
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
                    viewStore.send(.uploadMemberStatus)
                }
                .sheet(store: self.store.scope(state: \.$shareState,
                                                         action: \.fullScreenCoverShare)) { store in
                    MoreShareView(store: store)
                }
                .fullScreenCover(store: self.store.scope(state: \.$premiumState,
                                                         action: \.fullScreenCoverPremium)) { store in
                    PremiumMemberView(store: store)
                }
                .fullScreenCover(store: self.store.scope(state: \.$safariState,
                                                         action: \.fullScreenCoverSafari)) { store in
                    MoreSafariView(store: store)
                }
                .fullScreenCover(store: store.scope(state: \.$historyItem,
                                                    action: \.presentationHistoryMsg)) { store in
                    ConversationListView(store: store)
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
