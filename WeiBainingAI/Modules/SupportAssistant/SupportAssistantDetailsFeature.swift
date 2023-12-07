//
//  SupportAssistantDetailsFeature.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/27.
//

import Foundation
import ComposableArchitecture
import SVProgressHUD

@Reducer
struct SupportAssistantDetailsFeature {
    struct State: Equatable {
        var assistantTitle: String
        @PresentationState var albumState: ImagePickerFeature.State?
        var selectImageData: Data?
        @BindingState var editorText: String = ""
        var aspectRatios: [SupportAssistantDetailsModel.AssistantDetailsProportion]
        @BindingState var selectRatios: Int = 0
        var aspectStyles: [SupportAssistantDetailsModel.AssistantDetailsStyle]
        @BindingState var selectStyle: Int = 0
        var aspectImageFactors: [SupportAssistantDetailsModel.AssistantDetailsImageFactor]
        @BindingState var selectImageFactor: Int = 0
        var editModel = SupportAssistantDetailsModel()
        @PresentationState var makeState: SupportAssistantMakeFeature.State?
    }
    
    enum Action: BindableAction, Equatable {
        case dismissAlbum
        case fullScreenCoverAlbum(PresentationAction<ImagePickerFeature.Action>)
        case selectImageDetele
        case binding(BindingAction<State>)
        case dismissMake
        case fullScreenCoverMake(PresentationAction<SupportAssistantMakeFeature.Action>)
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .dismissAlbum:
                state.albumState = ImagePickerFeature.State(isAllowsEditing: true)
                return .none
            case let .fullScreenCoverAlbum(.presented(.delegate(.selectImage(data)))):
                state.selectImageData = data
                return .none
            case .selectImageDetele:
                state.selectImageData = nil
                return .none
            case .dismissMake:
                guard state.selectStyle < state.aspectStyles.count,
                      state.selectRatios < state.aspectRatios.count else {
                    SVProgressHUD.showError(withStatus: "当前服务不可用, 请稍候再试")
                    return .none
                }
                state.editModel.text = state.editorText
                state.editModel.proportion = state.aspectRatios[state.selectRatios]
                state.editModel.style = state.aspectStyles[state.selectStyle]
                state.editModel.referImageFactor = state.aspectImageFactors[state.selectImageFactor]
                switch state.editModel.style {
                case .style4, .style5:
                    guard state.selectImageData != nil else {
                        SVProgressHUD.showError(withStatus: "当前风格需要添加参考图")
                        return .none
                    }
                    guard state.selectImageFactor < state.aspectImageFactors.count else {
                        SVProgressHUD.showError(withStatus: "当前服务不可用, 请稍候再试")
                        return .none
                    }
                    state.makeState = SupportAssistantMakeFeature.State(extModel: state.editModel, imgData: state.selectImageData)
                    return .none
                default:
                    state.makeState = SupportAssistantMakeFeature.State(extModel: state.editModel, imgData: state.selectImageData)
                    return .none
                }
            case .fullScreenCoverMake(.presented(.delegate(.resultMakeDismiss))):
                return .run { _ in 
                    await self.dismiss()
                }
            default:
                return .none
            }
        }
        .ifLet(\.$albumState, action: \.fullScreenCoverAlbum) {
            ImagePickerFeature()
        }
        .ifLet(\.$makeState, action: \.fullScreenCoverMake) {
            SupportAssistantMakeFeature()
        }
    }
}
