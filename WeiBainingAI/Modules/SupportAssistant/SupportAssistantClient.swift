//
//  SupportAssistantClient.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/28.
//

import ComposableArchitecture
import Foundation

let assistatJson = """
[{"imgSign":"257663e7872aef1ae8470bf1d550e854","title":"AI艺术头像制作","content":"上传您喜欢的图片快速生成您的个性头像，让您与众不同。","type":"imageToAvatar","configuration":{"depictText":"","styles":[27],"imageFactors":[0.6],"proportions":[1]}},{"imgSign":"e3436025a39a154abd8a0a2e8f8f2467","title":"AI艺术壁纸制作","content":"通过您上传的图片即可借助人工智能技术生成精美的手机壁纸和插画图片。","type":"imageToWallpaper","configuration":{"depictText":"","styles":[19],"imageFactors":[0.6],"proportions":[4]}},{"imgSign":"257663e7872aef1ae8470bf1d550e854","title":"AI智能文字绘图","content":"通过您输入的文字内容动态识别，生成艺术图片，一切懂你所想。","type":"textToWallpaper","configuration":{"depictText":"","styles":[9],"imageFactors":[0.6],"proportions":[4]}},{"imgSign":"e3436025a39a154abd8a0a2e8f8f2467","title":"AI智能文字头像制作","content":"按照您的所思所想，识别您的文字需求，智能完成专属头像设计","type":"textToAvatar","configuration":{"depictText":"","styles":[9],"imageFactors":[0.6],"proportions":[1]}},{"imgSign":"257663e7872aef1ae8470bf1d550e854","title":"个性DIY绘图","content":"综合前沿的人工智能图像绘制能力，发挥您的想象力，满足每个人的diy梦想。","type":"aiDiy","configuration":{"depictText":"","styles":[8,12,16,26,27],"imageFactors":[0.2,0.4,0.6,0.8],"proportions":[1,2,3,4,5,6]}},{"imgSign":"257663e7872aef1ae8470bf1d550e854","title":"光影特效","content":"综合前沿的人工智能图像绘制能力，发挥您的想象力，满足每个人的diy梦想。","type":"lightShadow","configuration":{"depictText":"时尚摄影肖像，女孩，白色长裙晚礼服，腮红，唇彩，微笑，浅棕色头发，落肩，飘逸的羽毛装饰礼服，蓬松长发，柔和的光线，美丽的阴影，低调，逼真，原始照片，自然的皮肤纹理，逼真的眼睛和脸部细节，超现实主义，超高分辨率，4K，最佳质量，杰作，项链，乳白色","styles":[8,12,16,22,25],"imageFactors":[0.2],"proportions":[1,4]}},{"imgSign":"96736a4fb3891915ff7beee14846d766","title":"AI写作与灵感","content":"通过人工智能驱动的写作和灵感释放您的创造力。 毫不费力地制作引人入胜的内容、产生新的想法并完善您的写作。","type":"chat"}]
"""

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
         Self {
             guard let data = assistatJson.data(using: .utf8) else {
                 throw HttpErrorHandler.failedWithServer("解析失败")
             }
            return try JSONDecoder().decode([SupportAssistantModel].self, from: data)
//            throw Unimplemented("assistantItems not implemented")
        }
    }
}
