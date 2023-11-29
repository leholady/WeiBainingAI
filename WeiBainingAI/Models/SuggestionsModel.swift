//
//  SuggestionsModel.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/28.
//

import UIKit

struct SuggestionsModel: Codable, Equatable, Identifiable, Hashable {
    var id: String {
        UUID().uuidString
    }
    let title: String
}
