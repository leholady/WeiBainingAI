//
//  UserProfileModel.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/23.
//

import UIKit

struct UserProfileModel: Codable, Equatable {
    var userId: String?
    var SPSSID: String?
    var nickName: String?
    var isForever: Bool?
    var isVip: Bool?
    var isLogin: Bool?
    var vipExpireTime: Int?
}
