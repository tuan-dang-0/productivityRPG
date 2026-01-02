import SwiftUI
import UIKit

extension Font {
    static func playfair(_ size: CGFloat, weight: PlayfairWeight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .regular: fontName = "PlayfairDisplay-Regular"
        case .bold: fontName = "PlayfairDisplay-Bold"
        case .boldItalic: fontName = "PlayfairDisplay-BoldItalic"
        case .italic: fontName = "PlayfairDisplay-Italic"
        case .black: fontName = "PlayfairDisplay-Black"
        case .blackItalic: fontName = "PlayfairDisplay-BlackItalic"
        }
        return .custom(fontName, size: size)
    }
    
    enum PlayfairWeight {
        case regular, bold, boldItalic, italic, black, blackItalic
    }
    
    static var largeTitle: Font { .playfair(34, weight: .bold) }
    static var title: Font { .playfair(28, weight: .bold) }
    static var title2: Font { .playfair(22, weight: .bold) }
    static var title3: Font { .playfair(20, weight: .bold) }
    static var headline: Font { .playfair(17, weight: .bold) }
    static var body: Font { .playfair(17) }
    static var callout: Font { .playfair(16) }
    static var subheadline: Font { .playfair(15) }
    static var footnote: Font { .playfair(13) }
    static var caption: Font { .playfair(12) }
    static var caption2: Font { .playfair(11) }
}
