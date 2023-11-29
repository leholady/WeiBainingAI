//
//  SuggestionsModel.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/28.
//

import UIKit

struct SuggestionsModel: Codable, Equatable, Identifiable, Hashable {
    let id: String
    let title: String

    init(id: String = UUID().uuidString, title: String) {
        self.id = id
        self.title = title
    }
}
