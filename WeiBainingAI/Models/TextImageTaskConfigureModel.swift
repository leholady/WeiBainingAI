//
//  TextImageTaskConfigureModel.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/29.
//

import Foundation

struct TextImageTaskConfigureModel: Codable, Equatable {
    
    var server: TaskServer = .dream
    let ext: SupportAssistantDetailsModel
    
    struct TaskServer: RawRepresentable, Codable, Equatable {
        let rawValue: String
        static let dream = TaskServer(rawValue: "dream")
    }
}
