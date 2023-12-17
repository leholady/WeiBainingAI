//
//  SupportAssistantClient.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/28.
//

import ComposableArchitecture
import Foundation

struct SupportAssistantClient {
    var assistantItems: @Sendable () async throws -> [SupportAssistantModel]
}

extension SupportAssistantClient: TestDependencyKey {
    static var previewValue: SupportAssistantClient {
        Self {
            [
                SupportAssistantModel(imgSign: "257663e7872aef1ae8470bf1d550e854",
                                      title: "AI艺术头像制作",
                                      content: "上传您喜欢的图片快速生成您的个性头像，让您与众不同。",
                                      type: .imageToAvatar),
                SupportAssistantModel(imgSign: "e3436025a39a154abd8a0a2e8f8f2467",
                                      title: "AI艺术壁纸制作",
                                      content: "通过您上传的图片即可借助人工智能技术生成精美的手机壁纸和插画图片。",
                                      type: .imageToWallpaper),
                SupportAssistantModel(imgSign: "257663e7872aef1ae8470bf1d550e854",
                                      title: "AI智能文字绘图",
                                      content: "通过您输入的文字内容动态识别，生成艺术图片，一切懂你所想。",
                                      type: .textToWallpaper),
                SupportAssistantModel(imgSign: "e3436025a39a154abd8a0a2e8f8f2467",
                                      title: "AI智能文字头像制作",
                                      content: "按照您的所思所想，识别您的文字需求，智能完成专属头像设计",
                                      type: .textToAvatar),
                SupportAssistantModel(imgSign: "257663e7872aef1ae8470bf1d550e854",
                                      title: "个性DIY绘图",
                                      content: "综合前沿的人工智能图像绘制能力，发挥您的想象力，满足每个人的diy梦想。",
                                      type: .aiDiy),
                SupportAssistantModel(imgSign: "257663e7872aef1ae8470bf1d550e854",
                                      title: "光影特效",
                                      content: "综合前沿的人工智能图像绘制能力，发挥您的想象力，满足每个人的diy梦想。",
                                      type: .lightShadow),
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
        let handler = HttpRequestHandler()
        return Self {
             try await handler.getHomeAllAssistant()
        }
    }
}
