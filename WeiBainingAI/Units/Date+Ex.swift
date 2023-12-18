//
//  Date+Ex.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/29.
//

import SwiftUI
import UIKit

extension Date {
    /// 将时间类型格式化成字符串
    var timeFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: self)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
