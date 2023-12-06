//
//  SupportAssistantMakeFeature.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/29.
//

import Foundation
import ComposableArchitecture

enum AssistantMakeStatus {
    case normal
    case loading
    case success
    case failure
}

@Reducer
struct SupportAssistantMakeFeature {
    
    struct State: Equatable {
        var isDismiss: Bool = false
        var extModel: SupportAssistantDetailsModel
        var imgData: Data?
        var makeStatus: AssistantMakeStatus = .failure
        var progress: CGFloat = 0.0
        @PresentationState var resultState: SupportAssistantResultFeature.State?
        var isTimerRunning = false
    }
    
    enum Action: Equatable {
        case startMark
        case uploadMakeStatus(AssistantMakeStatus)
        case uploadImageSign(String)
        case txtToImageTask
        case judgmentTaskResult(TextImageTaskResultModel)
        case turnOnTimer
        case closureTimer
        case timerCountIncrement
        case progressCompleted
        case dismissResult(URL)
        case fullScreenCoverResult(PresentationAction<SupportAssistantResultFeature.Action>)
        case delegate(Delegate)
        enum Delegate: Equatable {
            case resultMakeDismiss
        }
    }
    
    enum CancelID { case timer }
    @Dependency(\.httpClient) var httpClient
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startMark:
                if state.extModel.referImageSign != nil {
                    return .run { send in
                        await send(.uploadMakeStatus(.loading))
                        await send(.txtToImageTask)
                        await send(.turnOnTimer)
                    }
                }
                if let data = state.imgData {
                    return .run { send in
                        await send(.uploadMakeStatus(.loading))
                        do {
                            let sign = try await httpClient.uploadImageSign(data)
                            await send(.uploadImageSign(sign))
                            await send(.txtToImageTask)
                            await send(.turnOnTimer)
                        } catch {
                            await send(.uploadMakeStatus(.failure))
                            await send(.closureTimer)
                        }
                    }
                }
                return .run { send in
                    await send(.uploadMakeStatus(.loading))
                    await send(.txtToImageTask)
                    await send(.turnOnTimer)
                }
            case let .uploadMakeStatus(status):
                if status == .failure {
                    state.progress = 0
                }
                state.makeStatus = status
                return .none
            case let .uploadImageSign(sign):
                state.extModel.referImageSign = sign
                return .none
            case .txtToImageTask:
                return .run { [extModel = state.extModel] send in
                    do {
                        var model = try await httpClient.txtToImageTask(TextImageTaskConfigureModel(ext: extModel))
                        while model.status == .doing {
                            try await Task.sleep(nanoseconds: 3_000_000_000)
                            model = try await httpClient.txtToImageResult(model.transcationId)
                        }
                        await send(.judgmentTaskResult(model))
                    } catch {
                        await send(.uploadMakeStatus(.failure))
                        await send(.closureTimer)
                    }
                }
            case let .judgmentTaskResult(result):
                switch result.status {
                case .success:
                    if let imageUrl = result.resImageUrl {
                        return .run { send in
                            await send(.uploadMakeStatus(.success))
                            await send(.closureTimer)
                            await send(.progressCompleted)
                            try await Task.sleep(nanoseconds: 500_000_000)
                            await send(.dismissResult(imageUrl))
                        }
                    }
                    return .run { send in
                        await send(.uploadMakeStatus(.failure))
                        await send(.closureTimer)
                    }
                default:
                    return .run { send in
                        await send(.uploadMakeStatus(.failure))
                        await send(.closureTimer)
                    }
                }
            case .turnOnTimer:
                return .run { send in
                    while true {
                        try await Task.sleep(nanoseconds: 100_000_000)
                        await send(.timerCountIncrement)
                    }
                }
                .cancellable(id: CancelID.timer)
            case .closureTimer:
                return .cancel(id: CancelID.timer)
            case .timerCountIncrement:
                if state.progress < 1 {
                    state.progress += 0.004
                }
                return .none
            case .progressCompleted:
                state.progress = 1
                return .none
            case let .dismissResult(imgUrl):
                state.resultState = SupportAssistantResultFeature.State(imgUrl: imgUrl)
                return .none
            case .fullScreenCoverResult(.presented(.delegate(.resultDismiss))):
                return .run { [isDismiss = state.isDismiss] send in
                    if isDismiss {
                        await self.dismiss()
                    } else {
                        await send(.delegate(.resultMakeDismiss))
                    }
                }
            default:
                return .none
            }
        }
        .ifLet(\.$resultState, action: \.fullScreenCoverResult) {
            SupportAssistantResultFeature()
        }
    }
}
