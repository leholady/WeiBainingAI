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
                SupportAssistantModel(imgSign: "home_icon_assistant_sel",
                                      title: "AI艺术头像制作",
                                      content: "头像生成器应用程序可让您通过上传图像和自定义不同的样式来创建独特的头像。"),
                SupportAssistantModel(imgSign: "home_icon_assistant_sel",
                                      title: "AI艺术壁纸制作",
                                      content: "通过我们的App使用您上传的图像创建独特的壁纸。 多种风格可供选择。"),
                SupportAssistantModel(imgSign: "home_icon_assistant_sel",
                                      title: "AI写作与灵感",
                                      content: "通过人工智能驱动的写作和灵感释放您的创造力。 毫不费力地制作引人入胜的内容、产生新的想法并完善您的写作。")
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
