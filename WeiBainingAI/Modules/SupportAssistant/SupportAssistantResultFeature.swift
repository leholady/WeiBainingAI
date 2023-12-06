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
        enum Delegate: Equatable {
            case resultDismiss
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .savePhotoAlbum:
                return .run { [url = state.imgUrl] _ in
                    await SVProgressHUD.show()
                    do {
                        let data = try Data(contentsOf: url)
                        guard let image = UIImage(data: data) else {
                            await SVProgressHUD.dismiss()
                            await SVProgressHUD.showSuccess(withStatus: "保存失败, 请稍候重试")
                            return
                        }
                        try await PHPhotoLibrary.shared().performChanges {
                            PHAssetChangeRequest.creationRequestForAsset(from: image)
                        }
                        await SVProgressHUD.dismiss()
                        await SVProgressHUD.showSuccess(withStatus: "已保存到相册")
                    } catch {
                        await SVProgressHUD.dismiss()
                        await SVProgressHUD.showError(withStatus: "保存失败, 请稍候重试")
                    }
                }
            default:
                return .none
            }
        }
    }
}
