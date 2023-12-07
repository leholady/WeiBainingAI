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
        var depictText: String
        @BindingState var lightShadowText: String = ""
        var aspectRatios: [SupportAssistantDetailsModel.AssistantDetailsProportion]
        @BindingState var selectRatios: Int = 0
        var aspectStyles: [SupportAssistantDetailsModel.AssistantDetailsStyle]
        @BindingState var selectStyle: Int = 0
        var aspectImageFactors: [SupportAssistantDetailsModel.AssistantDetailsImageFactor]
        @BindingState var selectImageFactor: Int = 0
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
                guard state.lightShadowText.count <= 3 else {
                    SVProgressHUD.showError(withStatus: "请注意，文字长度限制为 1~3字")
                    return .none
                }
                guard state.selectStyle < state.aspectStyles.count,
                      state.selectRatios < state.aspectRatios.count,
                      state.selectImageFactor < state.aspectImageFactors.count else {
                    SVProgressHUD.showError(withStatus: "当前服务不可用, 请稍候再试")
                    return .none
                }
                let model = SupportAssistantDetailsModel(text: state.depictText,
                                                         proportion: state.aspectRatios[state.selectRatios],
                                                         style: state.aspectStyles[state.selectStyle],
                                                         referImageFactor: state.aspectImageFactors[state.selectImageFactor],
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
