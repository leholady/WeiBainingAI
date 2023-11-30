//
//  SupportAssistantDetailsModel.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/27.
//

import Foundation

struct SupportAssistantDetailsModel: Codable, Equatable {
    
    var text: String = ""
    var proportion: AssistantDetailsProportion = .one
    var style: AssistantDetailsStyle = .automatic
    var referImageSign: String?
    var referImageFactor: AssistantDetailsImageFactor = .low

    struct AssistantDetailsImageFactor: RawRepresentable, Codable, Equatable, Hashable {
        var id: String {
            title
        }
        let rawValue: Double
        var title: String {
            switch self {
            case .low:
                return "低"
            case .middle:
                return "中"
            case .high:
                return "高"
            case .forced:
                return "强"
            default:
                return "低"
            }
        }
        static let low = AssistantDetailsImageFactor(rawValue: 0.2)
        static let middle = AssistantDetailsImageFactor(rawValue: 0.4)
        static let high = AssistantDetailsImageFactor(rawValue: 0.6)
        static let forced = AssistantDetailsImageFactor(rawValue: 0.8)
    }
    
    struct AssistantDetailsStyle: RawRepresentable, Codable, Equatable, Hashable {
        var id: String {
            title
        }
        let rawValue: Int
        var title: String {
            switch self {
            case .automatic:
                return "智能"
            case .style1:
                return "动漫"
            case .style2:
                return "写实"
            case .style3:
                return "卡通"
            case .style4:
                return "水彩"
            case .style5:
                return "足球宝贝"
            default:
                return "智能"
            }
        }
        static let automatic = AssistantDetailsStyle(rawValue: 1)
        static let style1 = AssistantDetailsStyle(rawValue: 2)
        static let style2 = AssistantDetailsStyle(rawValue: 3)
        static let style3 = AssistantDetailsStyle(rawValue: 4)
        static let style4 = AssistantDetailsStyle(rawValue: 5)
        static let style5 = AssistantDetailsStyle(rawValue: 6)
    }
    
    struct AssistantDetailsProportion: RawRepresentable, Codable, Equatable, Hashable {
        var id: String {
            title
        }
        let rawValue: Int
        var title: String {
            switch self {
            case .one:
                return "1:1"
            case .two:
                return "9:16"
            case .three:
                return "16:9"
            case .four:
                return "壁纸"
            case .five:
                return "3:4"
            case .six:
                return "4:3"
            default:
                return "1:1"
            }
        }
        static let one = AssistantDetailsProportion(rawValue: 1)
        static let two = AssistantDetailsProportion(rawValue: 2)
        static let three = AssistantDetailsProportion(rawValue: 3)
        static let four = AssistantDetailsProportion(rawValue: 4)
        static let five = AssistantDetailsProportion(rawValue: 5)
        static let six = AssistantDetailsProportion(rawValue: 6)
    }
}
