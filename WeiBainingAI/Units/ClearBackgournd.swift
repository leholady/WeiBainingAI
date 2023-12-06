//
//  ClearBackgournd.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/5.
//

import Foundation
import SwiftUI

struct BackgroundCleanerView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .black.withAlphaComponent(0.2)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

public extension View {
    @ViewBuilder
    func clearBackground(_ enable: Bool = true) -> some View {
        if enable {
            background(BackgroundCleanerView())
        } else {
            self
        }
    }
}
