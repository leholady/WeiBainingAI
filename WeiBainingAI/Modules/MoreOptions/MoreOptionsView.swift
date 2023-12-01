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
                        ForEach(viewStore.groups) { group in
                            Section(content: {
                                VStack {
                                    ForEach(group.items) { item in
                                        switch item {
                                        case .itemBalance:
                                            MoreOptionsBalanceCell(items: viewStore.balanceItems)
                                        default:
                                            MoreOptionsItemCell(item: item)
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
