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
        var assistants: [SupportAssistantModel] = []
        @PresentationState var details: SupportAssistantDetailsFeature.State?
    }
    
    enum Action: Equatable {
        case uploadAssistantItems
        case assistantsUpdate(TaskResult<[SupportAssistantModel]>)
        case dismissDetails(SupportAssistantModel)
        case fullScreenCoverDetails(PresentationAction<SupportAssistantDetailsFeature.Action>)
    }

    @Dependency(\.assistantClient) var assistantClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .uploadAssistantItems:
                return .run { send in
                    await send(.assistantsUpdate(
                        TaskResult {
                            try await assistantClient.assistantItems()
                        }
                    ))
                }
            case let .assistantsUpdate(.success(items)):
                state.assistants = items
                return .none
            case .assistantsUpdate(.failure):
                state.assistants = []
                return .none
            case let .dismissDetails(model):
                state.details = SupportAssistantDetailsFeature.State(assistantTitle: model.title,
                                                                     selectRatios: model.type == .wallpaper ? 3 : 0)
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$details, action: \.fullScreenCoverDetails) {
            SupportAssistantDetailsFeature()
        }
    }
}

extension DependencyValues {
    var assistantClient: SupportAssistantClient {
        get { self[SupportAssistantClient.self] }
        set { self[SupportAssistantClient.self] = newValue }
    }
}
