import SwiftUI
import UIKit

struct ScrollingTextView: UIViewRepresentable {
    var text: String

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .label
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail

        // 애니메이션을 적용하기 위한 설정
        DispatchQueue.main.async {
            if label.intrinsicContentSize.width > 200 {
                startScrollingAnimation(label: label)
            }
        }
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = text
    }

    private func startScrollingAnimation(label: UILabel) {
        let originalFrame = label.frame
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = originalFrame.width / 2
        animation.toValue = -(originalFrame.width / 2)
        animation.duration = 5
        animation.repeatCount = .infinity
        label.layer.add(animation, forKey: "scrolling")
    }
}