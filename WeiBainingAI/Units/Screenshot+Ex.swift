//
//  Screenshot+Ex.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/6.
//

import SwiftUI
import UIKit

// UIViewRepresentable包装，将SwiftUI视图植入到UIView中
struct SnapshotWrapper<Content: View>: UIViewRepresentable {
    let content: Content
    let completion: (UIImage) -> Void

    func makeUIView(context: Context) -> UIView {
        let hostingController = UIHostingController(rootView: content)
        // 设置一个透明的背景色
        hostingController.view.backgroundColor = .clear
        return hostingController.view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let renderer = UIGraphicsImageRenderer(bounds: uiView.bounds)
            let image = renderer.image { _ in
                uiView.drawHierarchy(in: uiView.bounds, afterScreenUpdates: true)
            }
            completion(image)
        }
    }
}

// SwiftUI视图扩展，添加截图功能
extension View {
    func snapshot(completion: @escaping (UIImage) -> Void) -> some View {
        SnapshotWrapper(content: self, completion: completion)
    }
}

public struct ScreenshotTableView<Content: View>: View {
    @Binding var shotting: Bool
    var completed: (UIImage) -> Void
    let content: Content

    public init(shotting: Binding<Bool>, completed: @escaping (UIImage) -> Void, @ViewBuilder content: () -> Content) {
        _shotting = shotting
        self.completed = completed
        self.content = content()
    }

    public var body: some View {
        func internalView(proxy: GeometryProxy) -> some View {
            if self.shotting {
                let frame = proxy.frame(in: .global)
                DispatchQueue.main.async {
                    let screenshot = self.content.takeScreenshot(frame: frame, afterScreenUpdates: true)
                    self.completed(screenshot)
                }
            }
            return Color.clear
        }

        return content.background(GeometryReader(content: internalView(proxy:)))
    }
}

public extension View {
    func takeScreenshot(frame: CGRect, afterScreenUpdates: Bool) -> UIImage {
        let hostingController = UIHostingController(rootView: self)
        hostingController.overrideUserInterfaceStyle = .unspecified
        hostingController.view.frame = frame
        // 设置一个透明的背景色
        hostingController.view.backgroundColor = .clear
        return hostingController.view.takeScreenshot(afterScreenUpdates: afterScreenUpdates)
    }
}

public extension UIView {
    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot!
    }

    func takeScreenshot(afterScreenUpdates: Bool) -> UIImage {
        if !responds(to: #selector(drawHierarchy(in:afterScreenUpdates:))) {
            return self.takeScreenshot()
        }
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot!
    }
}
