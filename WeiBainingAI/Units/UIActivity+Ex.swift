//
//  UIActivity+Ex.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/6.
//

import SwiftUI
import UIKit

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        var item = activityItems
        item.append("分享截图内容")
        
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.excludedActivityTypes = [
            .postToWeibo,
            .addToReadingList,
            .markupAsPDF,
            .postToTencentWeibo,
            .assignToContact,
            .copyToPasteboard,
            .message,
            .openInIBooks,
            .postToFlickr,
            .print
        ]
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
