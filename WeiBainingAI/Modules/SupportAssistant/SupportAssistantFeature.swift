//
//  SupportAssistantFeature.swift
//  WeiBainingAI
//
//  Created by MorningStar on 2023/11/24.
//

import ComposableArchitecture

@Reducer
struct SupportAssistantFeature {
    struct State: Equatable {
        #warning("To do")
        var somthing: String = "Hello world"
    }
    
    enum Action {
        #warning("To do")
        case doSomething
    }
    
    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            default:
                return .none
            }
        }
    }
}
