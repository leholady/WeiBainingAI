//
//  MoreBalanceItemModel.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/1.
//

import Foundation

struct MoreBalanceItemModel: Codable, Equatable, Identifiable {
    var id: String {
        title
    }
    var title: String
    var number: String
    var unit: String
}
