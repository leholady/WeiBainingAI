//
//  SupportAssistantDetailsModel.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/27.
//

import Foundation

struct SupportAssistantDetailsModel: Codable, Equatable {
    
    var text: String
    var proportion: AssistantDetailsProportion
    var style: AssistantDetailsStyle
    var referImageSign: String
    var referImageFactor: AssistantDetailsImageFactor

    struct AssistantDetailsImageFactor: RawRepresentable, Codable, Equatable, Hashable {
        var id: String {
            rawValue
        }
        let rawValue: String
        static let low = AssistantDetailsImageFactor(rawValue: "低")
        static let middle = AssistantDetailsImageFactor(rawValue: "中")
        static let high = AssistantDetailsImageFactor(rawValue: "高")
        static let forced = AssistantDetailsImageFactor(rawValue: "强")
    }
    
    struct AssistantDetailsStyle: RawRepresentable, Codable, Equatable, Hashable {
        var id: String {
            rawValue
        }
        let rawValue: String
        static let automatic = AssistantDetailsStyle(rawValue: "智能")
        static let style1 = AssistantDetailsStyle(rawValue: "动漫1")
        static let style2 = AssistantDetailsStyle(rawValue: "动漫2")
        static let style3 = AssistantDetailsStyle(rawValue: "动漫3")
        static let style4 = AssistantDetailsStyle(rawValue: "动漫4")
        static let style5 = AssistantDetailsStyle(rawValue: "动漫5")
    }
    
    struct AssistantDetailsProportion: RawRepresentable, Codable, Equatable, Hashable {
        var id: String {
            rawValue
        }
        let rawValue: String
        var intValue: Int {
            switch self {
            case .one:
                return 1
            case .two:
                return 2
            case .three:
                return 3
            case .four:
                return 4
            case .five:
                return 5
            case .six:
                return 6
            default:
                return 1
            }
        }
        static let one = AssistantDetailsProportion(rawValue: "1:1")
        static let two = AssistantDetailsProportion(rawValue: "9:16")
        static let three = AssistantDetailsProportion(rawValue: "16:9")
        static let four = AssistantDetailsProportion(rawValue: "9:18")
        static let five = AssistantDetailsProportion(rawValue: "3:4")
        static let six = AssistantDetailsProportion(rawValue: "4:3")
    }
}
