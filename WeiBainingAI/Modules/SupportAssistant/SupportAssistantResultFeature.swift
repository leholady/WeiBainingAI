//
//  SupportAssistantResultFeature.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/29.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct SupportAssistantResultFeature {
    
    struct State: Equatable {
        var imgUrl: URL
    }
    
    enum Action: Equatable {
        case savePhotoAlbum
        case delegate(Delegate)
        enum Delegate: Equatable {
            case resultDismiss
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .savePhotoAlbum:
                return .none
            default:
                return .none
            }
        }
    }
}
