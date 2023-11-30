//
//  SupportAssistantClient.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/28.
//

import ComposableArchitecture

struct SupportAssistantClient {
    var assistantItems: @Sendable () async throws -> [SupportAssistantModel]
}

extension SupportAssistantClient: TestDependencyKey {
    static var previewValue: SupportAssistantClient {
        Self {
            [
                SupportAssistantModel(imgSign: "257663e7872aef1ae8470bf1d550e854",
                                      title: "AI艺术头像制作",
                                      content: "头像生成器应用程序可让您通过上传图像和自定义不同的样式来创建独特的头像。",
                                      type: .avatar),
                SupportAssistantModel(imgSign: "e3436025a39a154abd8a0a2e8f8f2467",
                                      title: "AI艺术壁纸制作",
                                      content: "通过我们的App使用您上传的图像创建独特的壁纸。 多种风格可供选择。",
                                      type: .wallpaper),
                SupportAssistantModel(imgSign: "96736a4fb3891915ff7beee14846d766",
                                      title: "AI写作与灵感",
                                      content: "通过人工智能驱动的写作和灵感释放您的创造力。 毫不费力地制作引人入胜的内容、产生新的想法并完善您的写作。",
                                      type: .chat)
            ]
        }
    }
}

extension SupportAssistantClient: DependencyKey {
    
    static var liveValue: SupportAssistantClient {
         Self {
            throw Unimplemented("assistantItems not implemented")
        }
    }
}
