//
//  ImagePickerFeature.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/28.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ImagePickerFeature {
    struct State: Equatable {
        @BindingState var imgData: Data?
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case delegate(Delegate)
        enum Delegate: Equatable {
            case selectImage(Data?)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.$imgData):
                return .run { [imgData = state.imgData] send in
                    await send(.delegate(.selectImage(imgData)))
                    await self.dismiss()
                }
            default:
                return .none
            }
        }
    }
}
