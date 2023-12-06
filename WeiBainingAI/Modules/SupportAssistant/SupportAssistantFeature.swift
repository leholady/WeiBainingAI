//
//  SupportAssistantFeature.swift
//  WeiBainingAI
//
//  Created by MorningStar on 2023/11/24.
//

import ComposableArchitecture
import Foundation
import SVProgressHUD

@Reducer
struct SupportAssistantFeature {
    struct State: Equatable {
        var assistants: [SupportAssistantModel] = []
        @PresentationState var details: SupportAssistantDetailsFeature.State?
        @PresentationState var albumState: ImagePickerFeature.State?
        var selectImageData: Data?
        var markType: SupportAssistantModel.SupportAssistantType?
        @PresentationState var makeState: SupportAssistantMakeFeature.State?
        @PresentationState var textState: SupportAssistantTextFeature.State?
    }
    
    enum Action: Equatable {
        case uploadAssistantItems
        case assistantsUpdate(TaskResult<[SupportAssistantModel]>)
        case dismissDetails(SupportAssistantModel)
        case fullScreenCoverDetails(PresentationAction<SupportAssistantDetailsFeature.Action>)
        case dismissAlbum(SupportAssistantModel.SupportAssistantType)
        case fullScreenCoverAlbum(PresentationAction<ImagePickerFeature.Action>)
        case dismissMake
        case fullScreenCoverMake(PresentationAction<SupportAssistantMakeFeature.Action>)
        case dismissTextMake(SupportAssistantModel)
        case fullScreenCoverTextMake(PresentationAction<SupportAssistantTextFeature.Action>)
    }

    @Dependency(\.assistantClient) var assistantClient
    @Dependency(\.dismiss) var dismiss
    
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
                state.details = SupportAssistantDetailsFeature.State(assistantTitle: model.title)
                return .none
            case let .dismissAlbum(type):
                state.markType = type
                state.albumState = ImagePickerFeature.State(isAllowsEditing: type == .imageToAvatar)
                return .none
            case let .fullScreenCoverAlbum(.presented(.delegate(.selectImage(data)))):
                state.selectImageData = data
                return .run { send in
                    await send(.dismissMake)
                }
            case .dismissMake:
                guard let imgData = state.selectImageData,
                      let markType = state.markType else {
                    return .none
                }
                switch markType {
                case .imageToAvatar:
                    state.makeState = SupportAssistantMakeFeature.State(isDismiss: true,
                                                                        extModel: SupportAssistantDetailsModel(proportion: .one,
                                                                                                               style: .style27,
                                                                                                               referImageFactor: .high),
                                                                        imgData: imgData)
                case .imageToWallpaper:
                    state.makeState = SupportAssistantMakeFeature.State(isDismiss: true,
                                                                        extModel: SupportAssistantDetailsModel(proportion: .four,
                                                                                                               style: .style19,
                                                                                                               referImageFactor: .high),
                                                                        imgData: imgData)
                default:
                    break
                }
                return .none
            case .fullScreenCoverMake(.presented(.delegate(.resultMakeDismiss))):
                return .run { _ in
                    await self.dismiss()
                }
            case let .dismissTextMake(model):
                state.textState = SupportAssistantTextFeature.State(textTitle: model.title, editType: model.type)
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$details, action: \.fullScreenCoverDetails) {
            SupportAssistantDetailsFeature()
        }
        .ifLet(\.$albumState, action: \.fullScreenCoverAlbum) {
            ImagePickerFeature()
        }
        .ifLet(\.$makeState, action: \.fullScreenCoverMake) {
            SupportAssistantMakeFeature()
        }
        .ifLet(\.$textState, action: \.fullScreenCoverTextMake) {
            SupportAssistantTextFeature()
        }
    }
}

extension DependencyValues {
    var assistantClient: SupportAssistantClient {
        get { self[SupportAssistantClient.self] }
        set { self[SupportAssistantClient.self] = newValue }
    }
}
