//
//  HttpErrorHandler.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/23.
//

import UIKit

enum HttpErrorHandler: Error {
    case failedWithServer(String?)
    case failure(Error)
    case decodingFailed
    case noResponse
}
