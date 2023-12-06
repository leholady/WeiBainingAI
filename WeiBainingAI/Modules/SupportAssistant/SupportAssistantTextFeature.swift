//
//  SupportAssistantTextFeature.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/6.
//

import Foundation
import ComposableArchitecture
import SVProgressHUD

@Reducer
struct SupportAssistantTextFeature {
    struct State: Equatable {
        var textTitle: String
        var editType: SupportAssistantModel.SupportAssistantType
        @BindingState var editorText: String = ""
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
                guard !state.editorText.isEmpty else {
                    SVProgressHUD.showError(withStatus: "请输入文字提示")
                    return .none
                }
                state.makeState = SupportAssistantMakeFeature.State(extModel: SupportAssistantDetailsModel(text: state.editorText,
                                                                                                           proportion: state.editType == .textToAvatar ? .one : .four,
                                                                                                           style: .style9))
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
