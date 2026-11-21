import SwiftUI
import UIKit
import CoreText

// MARK: - Colour tokens

/// A light/dark pair taken from the design's `:root` and `:root[data-theme=dark]` variables.
struct Tint: Hashable {
    let light: UInt32
    let dark: UInt32

    static let page = Tint(light: 0xE4DED2, dark: 0x100F0D)
    static let bg = Tint(light: 0xEDE8DE, dark: 0x1A1815)
    static let card = Tint(light: 0xFBF9F4, dark: 0x24211D)
    static let chip = Tint(light: 0xF3EFE6, dark: 0x2E2A25)
    static let line = Tint(light: 0xDDD6C8, dark: 0x3A362F)
    static let line2 = Tint(light: 0xC4BBA9, dark: 0x524C42)
    static let mute2 = Tint(light: 0x9A9284, dark: 0x7A7366)
    static let muted = Tint(light: 0x6B665D, dark: 0xA8A193)
    static let body = Tint(light: 0x4A463F, dark: 0xCFC8BA)
    static let ink = Tint(light: 0x1F1D1A, dark: 0xF0EBE1)
    static let accent = Tint(light: 0x2F4A63, dark: 0xA9C4DE)
    static let accent2 = Tint(light: 0x3D5E7C, dark: 0xC0D5E9)
    static let rust = Tint(light: 0xB23A22, dark: 0xF08A72)
    static let green = Tint(light: 0x3F6B4C, dark: 0x8FCBA0)
    static let ochre = Tint(light: 0x8A5A14, dark: 0xE0B366)
    static let plum = Tint(light: 0x6A4A7A, dark: 0xC7A6DA)

    static let perceivable = accent
    static let operable = ochre
    static let understandable = green
    static let robust = plum

    /// Colour that adapts to light and dark automatically.
    var color: Color {
        Color(uiColor: UIColor { traits in
            UIColor(rgb: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }

    /// Fixed colour for one appearance — used inside `Canvas`, which draws outside the trait system.
    func resolved(dark isDark: Bool) -> Color { Color(rgb: isDark ? dark : light) }
}

extension UIColor {
    convenience init(rgb: UInt32, alpha: CGFloat = 1) {
        self.init(red: CGFloat((rgb >> 16) & 0xFF) / 255,
                  green: CGFloat((rgb >> 8) & 0xFF) / 255,
                  blue: CGFloat(rgb & 0xFF) / 255,
                  alpha: alpha)
    }
}

extension Color {
    init(rgb: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((rgb >> 16) & 0xFF) / 255,
                  green: Double((rgb >> 8) & 0xFF) / 255,
                  blue: Double(rgb & 0xFF) / 255,
                  opacity: opacity)
    }
}

/// Short names used throughout the views.
enum T {
    static var page: Color { Tint.page.color }
    static var bg: Color { Tint.bg.color }
    static var card: Color { Tint.card.color }
    static var chip: Color { Tint.chip.color }
    static var line: Color { Tint.line.color }
    static var line2: Color { Tint.line2.color }
    static var mute2: Color { Tint.mute2.color }
    static var muted: Color { Tint.muted.color }
    static var body: Color { Tint.body.color }
    static var ink: Color { Tint.ink.color }
    /// Text on an ink fill. In the design this is `#EDE8DE`, which dark mode maps to the page background.
    static var onInk: Color { Tint.bg.color }
    static var accent: Color { Tint.accent.color }
    static var rust: Color { Tint.rust.color }
    static var green: Color { Tint.green.color }
}

// MARK: - Fonts

enum Face {
    case serif, serifItalic
    case sans, sansMedium, sansBold
    case mono, monoSemibold

    var postScriptName: String {
        switch self {
        case .serif: return "Newsreader-Regular"
        case .serifItalic: return "Newsreader-Italic"
        case .sans: return "HankenGrotesk-Regular"
        case .sansMedium: return "HankenGrotesk-Medium"
        case .sansBold: return "HankenGrotesk-Bold"
        case .mono: return "JetBrainsMono-Regular"
        case .monoSemibold: return "JetBrainsMono-SemiBold"
        }
    }

    var isMono: Bool { self == .mono || self == .monoSemibold }
}

enum Fonts {
    /// Registers the bundled fonts once at launch. If a file is missing, `Font.custom` falls back to the system font.
    static func register() {
        let names = ["Newsreader-Regular", "Newsreader-Italic", "HankenGrotesk-Regular", "HankenGrotesk-Medium",
                     "HankenGrotesk-Bold", "JetBrainsMono-Regular", "JetBrainsMono-SemiBold"]
        for name in names {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    /// Picks the Dynamic Type style a design size should scale with.
    static func textStyle(for size: CGFloat) -> Font.TextStyle {
        switch size {
        case 34...: return .largeTitle
        case 26..<34: return .title
        case 20..<26: return .title3
        case 16..<20: return .body
        case 14..<16: return .subheadline
        default: return .footnote
        }
    }

    /// The design's pixel size, scaled by the in-app text size setting and by Dynamic Type.
    static func font(_ face: Face, _ size: CGFloat, scale: CGFloat) -> Font {
        Font.custom(face.postScriptName, size: size * scale, relativeTo: textStyle(for: size))
    }
}

private struct UIScaleKey: EnvironmentKey { static let defaultValue: CGFloat = 1 }
extension EnvironmentValues {
    /// The in-app text size (100 %, 115 %, 130 %) from You → Reading and motion.
    var uiScale: CGFloat {
        get { self[UIScaleKey.self] }
        set { self[UIScaleKey.self] = newValue }
    }
}

struct FaceModifier: ViewModifier {
    @Environment(\.uiScale) var scale
    let face: Face
    let size: CGFloat
    var tracking: CGFloat = 0
    var lineHeight: CGFloat? = nil

    func body(content: Content) -> some View {
        let font = Fonts.font(face, size, scale: scale)
        // CSS line-height → SwiftUI line spacing (extra space between lines).
        let spacing = lineHeight.map { max(0, ($0 - 1.2) * size * scale) } ?? 0
        content
            .font(font)
            .tracking(tracking * size * scale)
            .lineSpacing(spacing)
    }
}

extension View {
    /// `face(.serif, 46)` mirrors `font-family:'Newsreader';font-size:46px` from the design.
    func face(_ face: Face, _ size: CGFloat, tracking: CGFloat = 0, lineHeight: CGFloat? = nil) -> some View {
        modifier(FaceModifier(face: face, size: size, tracking: tracking, lineHeight: lineHeight))
    }

    /// The mono, letter-spaced kicker used above every section ("WHO IT HELPS").
    func kicker(_ color: Color = T.muted, size: CGFloat = 13, tracking: CGFloat = 0.1) -> some View {
        self.face(.mono, size, tracking: tracking).foregroundStyle(color)
    }
}

// MARK: - Appearance

enum ThemeChoice: String, Codable, CaseIterable {
    case auto, light, dark
    var label: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }

    var interfaceStyle: UIUserInterfaceStyle {
        switch self { case .auto: return .unspecified; case .light: return .light; case .dark: return .dark }
    }

    /// Applying the style to the window avoids SwiftUI's `preferredColorScheme(nil)` not reverting to Auto.
    func apply() {
        for scene in UIApplication.shared.connectedScenes {
            guard let ws = scene as? UIWindowScene else { continue }
            for w in ws.windows { w.overrideUserInterfaceStyle = interfaceStyle }
        }
    }
}
