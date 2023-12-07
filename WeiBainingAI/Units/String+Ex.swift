//
//  String+Ex.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/12/7.
//

import UIKit

extension String {
    
    func toImage(size: CGSize = CGSize(width: 500, height: 500),
                 maxFontSize: CGFloat = 200,
                 color: UIColor = .white) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { _ in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let newLine = count >= 4 ? 2 : 1
            var fontSize: CGFloat = 0
            var list = stride(from: 0, to: count, by: newLine).map {
                String(dropFirst($0).prefix(newLine))
            }
            fontSize = (size.height - 40 * CGFloat(list.count)) / CGFloat(list.count)
            if fontSize > maxFontSize {
                fontSize = maxFontSize
            }
            
            let attributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
                NSAttributedString.Key.foregroundColor: color.withAlphaComponent(0.3),
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]

            let textSize = (list.joined(separator: "\n") as NSString).size(withAttributes: attributes)

            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            self.draw(in: textRect, withAttributes: attributes)
        }
        return image
    }
}
