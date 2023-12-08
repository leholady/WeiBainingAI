//
//  SupportAssistantResultFeature.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/29.
//

import ComposableArchitecture
import SwiftUI
import PhotosUI
import SVProgressHUD

@Reducer
struct SupportAssistantResultFeature {
    
    struct State: Equatable {
        var imgUrl: URL
    }
    
    enum Action: Equatable {
        case savePhotoAlbum
        case delegate(Delegate)
        case hudShow
        case hudDismiss
        case hudFailure(String)
        case hudSuccess(String)
        enum Delegate: Equatable {
            case resultDismiss
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .savePhotoAlbum:
                return .run { [url = state.imgUrl] send in
                    await send(.hudShow)
                    do {
                        let data = try Data(contentsOf: url)
                        guard let image = UIImage(data: data) else {
                            await send(.hudDismiss)
                            await send(.hudFailure("保存失败, 请稍候重试"))
                            return
                        }
                        try await PHPhotoLibrary.shared().performChanges {
                            PHAssetChangeRequest.creationRequestForAsset(from: image)
                        }
                        await send(.hudDismiss)
                        await send(.hudSuccess("已保存到相册"))
                    } catch {
                        await send(.hudDismiss)
                        await send(.hudFailure("保存失败, 请稍候重试"))
                    }
                }
            case .hudShow:
                SVProgressHUD.show()
                return .none
            case .hudDismiss:
                SVProgressHUD.dismiss()
                return .none
            case let .hudSuccess(message):
                SVProgressHUD.showSuccess(withStatus: message)
                return .none
            case let .hudFailure(message):
                SVProgressHUD.showError(withStatus: message)
                return .none
            default:
                return .none
            }
        }
    }
}
