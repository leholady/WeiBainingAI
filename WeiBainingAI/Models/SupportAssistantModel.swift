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
    
    enum SupportAssistantType: String, Codable, Equatable {
        case avatar
        case wallpaper
        case chat
    }
}
