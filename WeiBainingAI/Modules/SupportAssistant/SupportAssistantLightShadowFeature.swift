//
//  SupportAssistantLightShadowFeature.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/7.
//

import ComposableArchitecture
import SVProgressHUD
import UIKit

@Reducer
struct SupportAssistantLightShadowFeature {
    struct State: Equatable {
        var textTitle: String
        @BindingState var lightShadowText: String = ""
        var aspectStyles: [SupportAssistantDetailsModel.AssistantDetailsStyle] = [.style8, .style12, .style16, .style22, .style25]
        @BindingState var selectStyle: Int = 0
        @PresentationState var makeState: SupportAssistantMakeFeature.State?
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case dismissMake
        case fullScreenCoverMake(PresentationAction<SupportAssistantMakeFeature.Action>)
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .dismissMake:
                guard !state.lightShadowText.isEmpty else {
                    SVProgressHUD.showError(withStatus: "请输入文字提示")
                    return .none
                }
                guard state.lightShadowText.count <= 4 else {
                    SVProgressHUD.showError(withStatus: "请注意，文字长度限制为 4 字符")
                    return .none
                }
                guard state.selectStyle < state.aspectStyles.count else {
                    SVProgressHUD.showError(withStatus: "当前服务不可用, 请稍候再试")
                    return .none
                }
                let model = SupportAssistantDetailsModel(text: "时尚摄影肖像，女孩，白色长裙晚礼服，腮红，唇彩，微笑，浅棕色头发，落肩，飘逸的羽毛装饰礼服，蓬松长发，柔和的光线，美丽的阴影，低调，逼真，原始照片，自然的皮肤纹理，逼真的眼睛和脸部细节，超现实主义，超高分辨率，4K，最佳质量，杰作，项链，乳白色",
                                                         proportion: .four,
                                                         style: state.aspectStyles[state.selectStyle],
                controlNetNname: "brightness")
                state.makeState = SupportAssistantMakeFeature.State(extModel: model, imgData: state.lightShadowText.toImage().pngData())
                return .none
            case .fullScreenCoverMake(.presented(.delegate(.resultMakeDismiss))):
                return .run { _ in
                    await self.dismiss()
                }
            default:
                return .none
            }
        }
        .ifLet(\.$makeState, action: \.fullScreenCoverMake) {
            SupportAssistantMakeFeature()
        }
    }
}
