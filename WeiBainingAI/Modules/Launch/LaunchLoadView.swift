//
//  LaunchLoadView.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/23.
//

import ComposableArchitecture
import SwiftUI

struct LaunchLoadView: View {
    let store: StoreOf<LaunchConfigReducer>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            switch viewStore.userProfile {
            case .none:
                ReloadConfigView(isReload: viewStore.loadError,
                                 privacyAuth: viewStore.privacyAuth) {
                    viewStore.send(.launchApp)
                } agreeAction: {
                    viewStore.send(.savePrivacyAuth(true))
                    viewStore.send(.loadConfig)
                } textTapAction: {
                    switch $0 {
                    case .privacy:
                        viewStore.send(.dismissSafari(HttpConst.privateUrl))
                    case .usage:
                        viewStore.send(.dismissSafari(HttpConst.usageUrl))
                    }
                }
                .onAppear {
                    viewStore.send(.loadPrivacyAuth)
                }
                .fullScreenCover(store: self.store.scope(state: \.$safariState,
                                                         action: \.fullScreenCoverSafari)) { store in
                    MoreSafariView(store: store)
                }
            default:
                TabHubView(store: Store(initialState: TabHubFeature.State(), reducer: {
                    TabHubFeature()
                }))
            }
        }
    }
}

enum ReloadConfigState {
    case privacy
    case usage
}

/// 显示重新加载视图
struct ReloadConfigView: View {
    var isReload: Bool
    var privacyAuth: Bool
    var action: () -> Void
    var agreeAction: () -> Void
    var textTapAction: (ReloadConfigState) -> Void
    
    let privacyContentText = """
    我们非常重视对您隐私的保护，在使用提供的服务前，请您仔细阅读如下声明。\n\n为了保证功能的完整性我们会在相应的使用场景下向您获取必要权限，经您授权给我们后使用。您可以拒绝或撤回授权，但可能导致部分产品功能使用受限。\n\n 为了保障提供给您更优质的服务，在您使用APP时，我们会搜集设备信息、崩溃日志等信息用于优化体验及错误统计分析，我们不会将您的信息共享给第三方或任何未经您授权的其他用途。\n\n在您阅读并同意我们的
    """

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
            VStack {
                Image("img_icon")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding(.top, 120)
                Spacer()
                if privacyAuth {
                    if isReload {
                        Text("获取数据失败，请重试")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                            .padding(.all, 20)
                        Text("请点击页面重试")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2)
                            .padding(.bottom, 20)
                    }
                }
            }
            .padding(30)
            if !privacyAuth {
                VStack(spacing: 15) {
                    Text("隐私保护")
                        .font(.system(size: 18, weight: .semibold))
                    ScrollView(.vertical, showsIndicators: false) {
                        Text("\(privacyContentText)[《隐私政策》](WeiBainingAI:privacy)\("和")[《用户协议》](WeiBainingAI:usage)\("后，继续使用我们的服务。")")
                            .font(.system(size: 12))
                            .lineSpacing(6)
                            .onOpenURL(perform: { url in
                                switch url.absoluteString {
                                case "WeiBainingAI:privacy":
                                    textTapAction(.privacy)
                                case "WeiBainingAI:usage":
                                    textTapAction(.usage)
                                default:
                                    break
                                }
                            })
                    }
                    .padding(.bottom, 15)
                    HStack {
                        Button {
                            exit(0)
                        } label: {
                            Text("不同意")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .frame(width: 140, height: 50)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(25)
                                .opacity(0.5)
                        }
                        Spacer()
                        Button {
                            agreeAction()
                        } label: {
                            Text("同意")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 140, height: 50)
                                .background(Color(hex: 0x027AFF))
                                .cornerRadius(25)
                        }
                    }
                }
                .foregroundColor(.black)
                .frame(height: 400)
                .padding(20)
                .background(.white)
                .cornerRadius(20)
                .padding(.horizontal, 40)
            }
        }
        .background(.black)
        .onTapGesture {
            if privacyAuth {
                action()
            }
        }
    }
}

#Preview {
    LaunchLoadView(store: Store(initialState: LaunchConfigReducer.State(), reducer: {
        LaunchConfigReducer()
    }))
}
