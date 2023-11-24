//
//  MessagingHubViewFeature.swift
//  WeiBainingAI
//
//  Created by MorningStar on 2023/11/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MessagingHubViewFeature {
    struct State: Equatable {
        #warning("To do")
        var somthing: String = "Hello world"
    }
    
    enum Action {
        case didTapHistoryButton
        case change
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .change:
                state.somthing = "\(Date.timeIntervalBetween1970AndReferenceDate)"
                return .none
            default:
                return .none
            }
        }
    }
}
