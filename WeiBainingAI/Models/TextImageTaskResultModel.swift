//
//  TextImageTaskResultModel.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/29.
//

import Foundation

struct TextImageTaskResultModel: Codable {
    
    var status: TaskResultStatus
    var transcationId: String
    var resImageUrl: URL?
    var err: String?
    
    struct TaskResultStatus: RawRepresentable, Codable, Equatable {
        let rawValue: String
        static let doing = TaskResultStatus(rawValue: "doing")
        static let success = TaskResultStatus(rawValue: "success")
        static let failure = TaskResultStatus(rawValue: "fail")
    }
}
