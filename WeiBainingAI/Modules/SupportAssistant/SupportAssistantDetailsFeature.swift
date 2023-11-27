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
        var somthing: String
        @BindingState var editorText: String = "输入所需的头像内容和风格例如：太空行走的小猫"
        var aspectRatios: [SupportAssistantDetailsModel.AssistantDetailsProportion] = [.one, .two, .three, .four, .five, .six]
        @BindingState var selectRatios: Int = 0
        var aspectStyles: [SupportAssistantDetailsModel.AssistantDetailsStyle] = [.automatic, .style1, .style2, .style3, .style4, .style5]
        @BindingState var selectStyle: Int = 0
        var aspectImageFactors: [SupportAssistantDetailsModel.AssistantDetailsImageFactor] = [.low, .middle, .high, .forced]
        @BindingState var selectImageFactor: Int = 0
    }
    
    enum Action: Equatable {
        case textEditorChanged(String)
        case aspectRatioChanged(Int)
        case aspectStyleChanged(Int)
        case aspectImageFactorChanged(Int)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .textEditorChanged(text):
                state.editorText = text
                return .none
            case let .aspectRatioChanged(ratio):
                state.selectRatios = ratio
                return .none
            case let .aspectStyleChanged(style):
                state.selectStyle = style
                return .none
            case let .aspectImageFactorChanged(style):
                state.selectImageFactor = style
                return .none
//            default:
//                return .none
            }
        }
    }
}
