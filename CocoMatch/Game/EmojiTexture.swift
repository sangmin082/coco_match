import UIKit

/// 이모지를 파스텔 배경 위에 그려 3D 블록 텍스처로 사용한다.
/// 별도 아트 에셋 없이 귀여운 장난감 블록 룩을 만드는 MVP 전략.
enum EmojiTexture {
    private static var cache: [ItemType: UIImage] = [:]

    static func image(for type: ItemType) -> UIImage {
        if let cached = cache[type] { return cached }
        let size: CGFloat = 256
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let image = renderer.image { context in
            type.color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: size, height: size))
            let text = NSAttributedString(
                string: type.emoji,
                attributes: [.font: UIFont.systemFont(ofSize: size * 0.6)]
            )
            let textSize = text.size()
            text.draw(at: CGPoint(x: (size - textSize.width) / 2,
                                  y: (size - textSize.height) / 2))
        }
        cache[type] = image
        return image
    }
}
