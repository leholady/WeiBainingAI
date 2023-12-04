//
//  PremiumMemberModel.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/2.
//

import Foundation
import StoreKit

struct PremiumMemberResultModel: Codable {
    var datas: [PremiumMemberModel]
}

struct PremiumMemberModel: Codable, Equatable, Identifiable, Hashable {
    var id: String {
        productId
    }
    
    var productId: String
    var state: PremiumMemberPageModel.PremiumMemberPageState
    
    var title: String?
    var duration: Int?
    var unit: String?
    
    var price: String?
    var code: String?
    var symbol: String?
    
    func newModelTo(_ product: Product) -> PremiumMemberModel {
        var model = self
        switch model.state {
        case .quota:
            model.title = product.displayName.isEmpty ? "\(model.duration ?? 0)\(model.unit ?? "")" : product.displayName
        default:
            model.title = product.displayName.isEmpty ? model.title : product.displayName
        }
        model.price = product.displayPrice
        model.code = product.format.currencyCode
        model.symbol = product.format.currencySymbol
        return model
    }
}

extension Product {
    var format: NumberFormatter {
        let format = NumberFormatter()
        format.locale = priceFormatStyle.locale
        return format
    }
}
