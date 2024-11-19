import SwiftUI
import UIKit

struct ScrollingTextView: UIViewRepresentable {
    var text: String
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .gray
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        
        // 애니메이션을 적용하기 위한 설정
        DispatchQueue.main.async {
            if label.intrinsicContentSize.width > 270 {
                startScrollingAnimation(label: label)
            }
        }
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = text
    }
    
    private func startScrollingAnimation(label: UILabel) {
        // 레이블을 오른쪽 바깥에서 시작하도록 설정
        let originalFrame = label.frame
        let containerWidth: CGFloat = 270
        let labelWidth = label.intrinsicContentSize.width
        
        // 초기 위치 설정
        label.frame = CGRect(x: containerWidth, y: originalFrame.origin.y, width: labelWidth, height: originalFrame.height)
        
        // 오른쪽에서 왼쪽으로 이동하는 애니메이션
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = containerWidth + labelWidth / 2 // 오른쪽 바깥 시작 위치
        animation.toValue = -labelWidth / 2                  // 왼쪽 바깥 끝 위치
        animation.duration = 5
        animation.repeatCount = .infinity
        animation.beginTime = CACurrentMediaTime() + 1       // 1초 지연 후 시작
        
        // 애니메이션 추가
        label.layer.add(animation, forKey: "scrolling")
    }
}
