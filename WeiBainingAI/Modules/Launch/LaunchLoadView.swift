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
    请您仔细阅与您隐私相关的简要说明，并在您仔细阅读我们的协议并同意后继续使用我们的服务。
    只有当您开启相关功能或使用相关服务时，为实现相关功能、服务，我们才会处理您的对应信息。对您数据通过加密隧道进行传输，我们不会监控、记录、收集、分享您的任何数据，确保您的隐私数据安全且匿名。如您不开启相关功能或使用相关服务，则我们不会处理您对应的信息。
    您应严格遵守当地法律法规使用我们的加速服务,我们将秉承遵守国内法律法规的原则，相关加速仅为中国大陆地区可合法访问的网站、App提供加速服务。
    在您使用APP的其他功能时，我们可能会收集您的设备信息、错误日志、统计相关的数据，用于App的优化、Bug修复、数据统计、防止欺诈行为,这些信息均不会与您的个人身份相关联。

    请仔细阅读我们的
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
            .padding(30)
            if !privacyAuth {
                VStack(spacing: 30) {
                    Text("隐私保护")
                        .font(.system(size: 18, weight: .semibold))
                    ScrollView(.vertical, showsIndicators: false) {
                        Text("\(privacyContentText)[《隐私政策》](WeiBainingAI:privacy)\("和")[《用户协议》](WeiBainingAI:usage)\("后，确认同意继续使用我们的服务。")")
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
