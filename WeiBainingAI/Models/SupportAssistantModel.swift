//
//  SupportAssistantModel.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/27.
//

import Foundation

struct SupportAssistantModel: Codable, Equatable, Identifiable {
    var id: String {
        UUID().uuidString
    }
    
    var imgSign: String
    var title: String
    var content: String
    var type: SupportAssistantType
    var configuration: SupportAssistantConfiguration?
    
    struct SupportAssistantConfiguration: Codable, Equatable {
        var depictText: String?
        var styles: [SupportAssistantDetailsModel.AssistantDetailsStyle]?
        var imageFactors: [SupportAssistantDetailsModel.AssistantDetailsImageFactor]?
        var proportions: [SupportAssistantDetailsModel.AssistantDetailsProportion]?
    }
    
    struct SupportAssistantType: RawRepresentable, Codable, Equatable, Hashable {
        var id: String {
            rawValue
        }
        let rawValue: String
        static let imageToAvatar = SupportAssistantType(rawValue: "imageToAvatar")
        static let imageToWallpaper = SupportAssistantType(rawValue: "imageToWallpaper")
        static let textToAvatar = SupportAssistantType(rawValue: "textToAvatar")
        static let textToWallpaper = SupportAssistantType(rawValue: "textToWallpaper")
        static let aiDiy = SupportAssistantType(rawValue: "aiDiy")
        static let lightShadow = SupportAssistantType(rawValue: "lightShadow")
        static let chat = SupportAssistantType(rawValue: "chat")
    }
}
