//
//  PremiumMemberModel.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/2.
//

import Foundation

struct PremiumMemberModel: Codable, Equatable, Identifiable, Hashable {
    var id: String {
        productId
    }
    
    var productId: String
    var title: String
}
