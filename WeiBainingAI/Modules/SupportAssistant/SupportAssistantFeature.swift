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
        var markModel: SupportAssistantModel?
        @PresentationState var makeState: SupportAssistantMakeFeature.State?
        @PresentationState var textState: SupportAssistantTextFeature.State?
        @PresentationState var lightShadowState: SupportAssistantLightShadowFeature.State?
    }
    
    enum Action: Equatable {
        case uploadAssistantItems
        case assistantsUpdate(TaskResult<[SupportAssistantModel]>)
        case dismissDetails(SupportAssistantModel)
        case fullScreenCoverDetails(PresentationAction<SupportAssistantDetailsFeature.Action>)
        case dismissAlbum(SupportAssistantModel)
        case fullScreenCoverAlbum(PresentationAction<ImagePickerFeature.Action>)
        case dismissMake
        case fullScreenCoverMake(PresentationAction<SupportAssistantMakeFeature.Action>)
        case dismissTextMake(SupportAssistantModel)
        case fullScreenCoverTextMake(PresentationAction<SupportAssistantTextFeature.Action>)
        case dismissLightShadow(SupportAssistantModel)
        case fullScreenCoverLightShadow(PresentationAction<SupportAssistantLightShadowFeature.Action>)
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
            case let .dismissDetails(model):
                state.details = SupportAssistantDetailsFeature.State(assistantTitle: model.title,
                                                                     editorText: model.configuration?.depictText ?? "",
                                                                     aspectRatios: model.configuration?.proportions ?? [.one, .two, .three, .four, .five, .six],
                                                                     aspectStyles: model.configuration?.styles ?? [.style8, .style26, .style12, .style16, .style27],
                                                                     aspectImageFactors: model.configuration?.imageFactors ?? [.low, .middle, .high, .forced])
                return .none
            case let .dismissAlbum(model):
                state.markModel = model
                state.albumState = ImagePickerFeature.State(isAllowsEditing: model.type == .imageToAvatar)
                return .none
            case let .fullScreenCoverAlbum(.presented(.delegate(.selectImage(data)))):
                state.selectImageData = data
                return .run { send in
                    await send(.dismissMake)
                }
            case .dismissMake:
                guard let imgData = state.selectImageData,
                      let markModel = state.markModel else {
                    return .none
                }
                switch markModel.type {
                case .imageToAvatar:
                    state.makeState = SupportAssistantMakeFeature.State(isDismiss: true,
                                                                        extModel: SupportAssistantDetailsModel(proportion: .one,
                                                                                                               style: markModel.configuration?.styles?.first ?? .style27,
                                                                                                               referImageFactor: markModel.configuration?.imageFactors?.first ?? .high),
                                                                        imgData: imgData)
                case .imageToWallpaper:
                    state.makeState = SupportAssistantMakeFeature.State(isDismiss: true,
                                                                        extModel: SupportAssistantDetailsModel(proportion: .four,
                                                                                                               style: markModel.configuration?.styles?.first ?? .style19,
                                                                                                               referImageFactor: markModel.configuration?.imageFactors?.first ?? .high),
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
                state.textState = SupportAssistantTextFeature.State(textTitle: model.title,
                                                                    editType: model.type,
                                                                    editorText: model.configuration?.depictText ?? "",
                                                                    aspectStyles: model.configuration?.styles ?? [.style9])
                return .none
            case let .dismissLightShadow(model):
                state.lightShadowState = SupportAssistantLightShadowFeature.State(textTitle: model.title,
                                                                                  depictText: model.configuration?.depictText ?? "时尚摄影肖像，女孩，白色长裙晚礼服，腮红，唇彩，微笑，浅棕色头发，落肩，飘逸的羽毛装饰礼服，蓬松长发，柔和的光线，美丽的阴影，低调，逼真，原始照片，自然的皮肤纹理，逼真的眼睛和脸部细节，超现实主义，超高分辨率，4K，最佳质量，杰作，项链，乳白色",
                                                                                  aspectRatios: model.configuration?.proportions ?? [.four],
                                                                                  aspectStyles: model.configuration?.styles ?? [.style8, .style12, .style16, .style22, .style25], aspectImageFactors: model.configuration?.imageFactors ?? [.low])
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
        .ifLet(\.$lightShadowState, action: \.fullScreenCoverLightShadow) {
            SupportAssistantLightShadowFeature()
        }
    }
}

extension DependencyValues {
    var assistantClient: SupportAssistantClient {
        get { self[SupportAssistantClient.self] }
        set { self[SupportAssistantClient.self] = newValue }
    }
}
