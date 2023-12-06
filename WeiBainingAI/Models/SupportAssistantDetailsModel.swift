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
    var style: AssistantDetailsStyle = .style1
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
            case .style1:
                return "基础"
            case .style2:
                return "动漫风"
            case .style3:
                return "经典动漫"
            case .style4:
                return "萌宠"
            case .style5:
                return "异次元头像"
            case .style6:
                return "足球宝贝"
            case .style7:
                return "剪纸"
            case .style8:
                return "超拟真"
            case .style9:
                return "摄影Pro"
            case .style10:
                return "基础Pro"
            case .style11:
                return "溢彩"
            case .style12:
                return "流光"
            case .style13:
                return "暗彩"
            case .style14:
                return "复古"
            case .style15:
                return "美漫"
            case .style16:
                return "缤纷"
            case .style17:
                return "水彩"
            case .style18:
                return "神秘"
            case .style19:
                return "写真"
            case .style20:
                return "皮克斯"
            case .style21:
                return "混血"
            case .style22:
                return "东方"
            case .style23:
                return "千金"
            case .style24:
                return "2.5D"
            case .style25:
                return "柔光"
            case .style26:
                return "靓彩"
            case .style27:
                return "动漫mix"
            case .style28:
                return "初代"
            default:
                return "智能"
            }
        }
        static let style1 = AssistantDetailsStyle(rawValue: 1)
        static let style2 = AssistantDetailsStyle(rawValue: 2)
        static let style3 = AssistantDetailsStyle(rawValue: 3)
        static let style4 = AssistantDetailsStyle(rawValue: 4)
        static let style5 = AssistantDetailsStyle(rawValue: 5)
        static let style6 = AssistantDetailsStyle(rawValue: 6)
        static let style7 = AssistantDetailsStyle(rawValue: 7)
        static let style8 = AssistantDetailsStyle(rawValue: 8)
        static let style9 = AssistantDetailsStyle(rawValue: 9)
        static let style10 = AssistantDetailsStyle(rawValue: 10)
        static let style11 = AssistantDetailsStyle(rawValue: 11)
        static let style12 = AssistantDetailsStyle(rawValue: 12)
        static let style13 = AssistantDetailsStyle(rawValue: 13)
        static let style14 = AssistantDetailsStyle(rawValue: 14)
        static let style15 = AssistantDetailsStyle(rawValue: 15)
        static let style16 = AssistantDetailsStyle(rawValue: 16)
        static let style17 = AssistantDetailsStyle(rawValue: 17)
        static let style18 = AssistantDetailsStyle(rawValue: 18)
        static let style19 = AssistantDetailsStyle(rawValue: 19)
        static let style20 = AssistantDetailsStyle(rawValue: 20)
        static let style21 = AssistantDetailsStyle(rawValue: 21)
        static let style22 = AssistantDetailsStyle(rawValue: 22)
        static let style23 = AssistantDetailsStyle(rawValue: 23)
        static let style24 = AssistantDetailsStyle(rawValue: 24)
        static let style25 = AssistantDetailsStyle(rawValue: 25)
        static let style26 = AssistantDetailsStyle(rawValue: 26)
        static let style27 = AssistantDetailsStyle(rawValue: 27)
        static let style28 = AssistantDetailsStyle(rawValue: 28)
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
