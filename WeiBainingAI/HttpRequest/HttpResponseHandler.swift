//
//  HttpResponseHandler.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/23.
//  网络请求返回处理

import UIKit
struct HttpResponseStatus: RawRepresentable, Codable, Equatable {
    let rawValue: String

    static let unknown = HttpResponseStatus(rawValue: "unknown")
    static let success = HttpResponseStatus(rawValue: "ok")
    static let needLogin = HttpResponseStatus(rawValue: "err.auth.loginNeed")
    static let error = HttpResponseStatus(rawValue: "error")
}

struct HttpResponseTimestamp: Codable {
    let timestamp: Int
}

struct HttpResponseHandler<T: Codable>: Codable {
    let err: HttpResponseStatus
    var res: T?
    var errUserMsg: String?

    enum CodingKeys: String, CodingKey {
        case err
        case res
        case errUserMsg
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        res = try container.decodeIfPresent(T.self, forKey: .res)
        err = (try? container.decode(HttpResponseStatus.self, forKey: .err)) ?? .unknown
        errUserMsg = (try? container.decode(String.self, forKey: .errUserMsg)) ?? "unknown"
    }
}
