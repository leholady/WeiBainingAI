//
//  SupportAssistantDetailsFeature.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/27.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SupportAssistantDetailsFeature {
    struct State: Equatable {
        var assistantTitle: String
        @PresentationState var albumState: ImagePickerFeature.State?
        var selectImageData: Data?
        @BindingState var editorText: String = ""
        var aspectRatios: [SupportAssistantDetailsModel.AssistantDetailsProportion] = [.one, .two, .three, .four, .five, .six]
        @BindingState var selectRatios: Int = 0
        var aspectStyles: [SupportAssistantDetailsModel.AssistantDetailsStyle] = [.automatic, .style1, .style2, .style3, .style4, .style5]
        @BindingState var selectStyle: Int = 0
        var aspectImageFactors: [SupportAssistantDetailsModel.AssistantDetailsImageFactor] = [.low, .middle, .high, .forced]
        @BindingState var selectImageFactor: Int = 0
        var editModel = SupportAssistantDetailsModel()
    }
    
    enum Action: BindableAction, Equatable {
        case dismissAlbum
        case fullScreenCoverAlbum(PresentationAction<ImagePickerFeature.Action>)
        case selectImageDetele
        case binding(BindingAction<State>)
        case generateStart
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .dismissAlbum:
                state.albumState = ImagePickerFeature.State()
                return .none
            case let .fullScreenCoverAlbum(.presented(.delegate(.selectImage(data)))):
                state.selectImageData = data
                return .none
            case .selectImageDetele:
                state.selectImageData = nil
                return .none
            case .generateStart:
                //                state.editModel.text = state.editorText
                //                state.editModel.proportion = state.aspectRatios[state.selectRatios]
                //                state.editModel.style = state.aspectStyles[state.selectStyle]
                //                state.editModel.referImageFactor = state.aspectImageFactors[state.selectImageFactor]
                //                if let data = try? JSONEncoder().encode(state.editModel),
                //                   let json = String(data: data, encoding: .utf8) {
                //                    debugPrint("==========\(json)=============")
                //                }
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$albumState, action: \.fullScreenCoverAlbum) {
            ImagePickerFeature()
        }
    }
}
