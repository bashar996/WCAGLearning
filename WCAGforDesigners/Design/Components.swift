import SwiftUI

// MARK: - Layout environment

/// How the current window is laid out. Set once at the root from the window size.
struct LayoutInfo: Equatable {
    /// Two pages side by side, split at the fold (iPhone Duo open, landscape, iPad).
    var spread = false
    /// Width of the overview page (the first page in reading order).
    var firstPageWidth: CGFloat = 0
    /// Vertical control bar on the physical right edge instead of a bottom tab bar.
    var rail = false
}

private struct LayoutKey: EnvironmentKey { static let defaultValue = LayoutInfo() }
extension EnvironmentValues {
    var layout: LayoutInfo {
        get { self[LayoutKey.self] }
        set { self[LayoutKey.self] = newValue }
    }
}

/// One screen, one job. In a spread the overview page and the working page each scroll on their own and
/// nothing crosses the fold. On a single screen they stack into one column.
struct PageSpread<First: View, Second: View>: View {
    var resetID: AnyHashable = 0
    var spacing: CGFloat = 28
    @ViewBuilder var first: First
    @ViewBuilder var second: Second

    @Environment(\.layout) var layout

    var body: some View {
        if layout.spread {
            HStack(spacing: 0) {
                page { first }
                    .frame(width: layout.firstPageWidth)
                Rectangle().fill(T.line).frame(width: 1).accessibilityHidden(true)
                page { second }
                    .frame(maxWidth: .infinity)
            }
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: spacing) {
                    first
                    second
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 44)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
            .id(resetID)
        }
    }

    private func page<V: View>(@ViewBuilder _ v: () -> V) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: spacing) { v() }
                .padding(.horizontal, 24)
                // Spreads often have no top safe area (the status bar moves to the side),
                // so give the page its own breathing room at the top.
                .padding(.top, 28)
                .padding(.bottom, 44)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .id(resetID)
    }
}

// MARK: - Flow layout

/// Wrapping row, like CSS `flex-wrap: wrap`.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxW = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, lineH: CGFloat = 0, widest: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            let w = min(s.width, maxW)
            if x > 0 && x + w > maxW { y += lineH + lineSpacing; x = 0; lineH = 0 }
            x += w + spacing
            lineH = max(lineH, s.height)
            widest = max(widest, x - spacing)
        }
        return CGSize(width: proposal.width ?? widest, height: y + lineH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            let w = min(s.width, bounds.width)
            if x > bounds.minX && x + w > bounds.maxX { y += lineH + lineSpacing; x = bounds.minX; lineH = 0 }
            v.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(width: w, height: s.height))
            x += w + spacing
            lineH = max(lineH, s.height)
        }
    }
}

// MARK: - Paper background

/// Warm paper with three soft colour blobs, as in the design.
struct PaperBackground: View {
    @Environment(\.colorScheme) var scheme
    var body: some View {
        GeometryReader { geo in
            ZStack {
                T.bg
                blob(Color(rgb: 0xF4C9A6, opacity: 0.8), 420).position(x: 50, y: 70)
                blob(Color(rgb: 0xBFE3D0, opacity: 0.6), 460).position(x: geo.size.width + 30, y: geo.size.height * 0.34 + 230)
                blob(Color(rgb: 0xF1C2B6, opacity: 0.5), 380).position(x: geo.size.width * 0.1 + 190, y: geo.size.height + 10)
            }
            .opacity(1)
        }
        .overlay { if scheme == .dark { T.bg.opacity(0.78) } }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private func blob(_ c: Color, _ d: CGFloat) -> some View {
        Circle()
            .fill(RadialGradient(colors: [c, c.opacity(0)], center: .center, startRadius: 0, endRadius: d / 2))
            .frame(width: d, height: d)
    }
}

// MARK: - Buttons

/// Fully rounded button. `filled` uses `fill` for the background and `onFill` for the label.
struct PillButtonStyle: ButtonStyle {
    var fill: Color? = nil
    var onFill: Color = T.onInk
    var border: Color = T.ink
    var height: CGFloat = 52
    var size: CGFloat = 16

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .face(.sansBold, size)
            .foregroundStyle(fill == nil ? T.ink : onFill)
            .frame(maxWidth: .infinity, minHeight: height)
            .padding(.horizontal, 18)
            .background(Capsule().fill(fill ?? Color.clear))
            .overlay { if fill == nil { Capsule().strokeBorder(border, lineWidth: 1) } }
            .contentShape(Capsule())
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

/// Plain pressable row/card with a subtle press state.
struct PressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// Radio chip: ink when selected, outlined otherwise. Selection is shown by fill and weight, not colour alone.
struct Chip: View {
    let label: String
    let on: Bool
    var height: CGFloat = 44
    var size: CGFloat = 14
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .face(on ? .sansBold : .sansMedium, size)
                .lineLimit(1)
                .fixedSize()
                .foregroundStyle(on ? T.onInk : T.ink)
                .padding(.horizontal, 16)
                .frame(minHeight: height)
                .background(Capsule().fill(on ? T.ink : Color.clear))
                .overlay(Capsule().strokeBorder(on ? T.ink : T.mute2, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(PressStyle())
        .accessibilityAddTraits(on ? [.isSelected] : [])
    }
}

/// Level pill: AA filled, AAA dashed, A outlined.
struct LevelBadge: View {
    let level: Level
    var prefix = ""
    var minWidth: CGFloat = 44
    var height: CGFloat = 26
    var size: CGFloat = 12

    var body: some View {
        let shape = Capsule()
        Text(prefix + level.rawValue)
            .face(.monoSemibold, size)
            .foregroundStyle(level == .aa ? T.onInk : T.ink)
            .padding(.horizontal, prefix.isEmpty ? 8 : 12)
            .frame(minWidth: minWidth, minHeight: height)
            .background(shape.fill(level == .aa ? T.ink : Color.clear))
            .overlay {
                switch level {
                case .aa: EmptyView()
                case .aaa: shape.strokeBorder(T.muted, style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                case .a: shape.strokeBorder(T.muted, lineWidth: 1)
                }
            }
            .accessibilityLabel("Level \(level.rawValue)")
    }
}

/// On/off switch drawn like the design: a 52×32 track, knob slides, fill shows state.
struct DesignSwitch: View {
    let on: Bool
    var tint: Color = T.ink
    var body: some View {
        Capsule()
            .fill(on ? tint : Color.clear)
            .overlay(Capsule().strokeBorder(T.muted, lineWidth: 1))
            .frame(width: 52, height: 32)
            .overlay(alignment: on ? .trailing : .leading) {
                Circle().fill(on ? T.onInk : T.ink).frame(width: 24, height: 24).padding(.horizontal, 4)
            }
            .animation(.snappy(duration: 0.2), value: on)
            .accessibilityHidden(true)
    }
}

struct SwitchRow: View {
    let label: String
    let desc: String
    let on: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).face(.sansMedium, 17).foregroundStyle(T.ink)
                    Text(desc).face(.sans, 14, lineHeight: 1.4).foregroundStyle(T.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                DesignSwitch(on: on)
            }
            .padding(.vertical, 10)
            .frame(minHeight: 68)
        }
        .buttonStyle(PressStyle())
        .overlay(alignment: .bottom) { Rectangle().fill(T.line).frame(height: 1) }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(on ? "On" : "Off")
    }
}

// MARK: - Text helpers

/// Big Newsreader heading.
struct Headline: View {
    let text: String
    var size: CGFloat = 52
    var body: some View {
        Text(text)
            .face(.serif, size, lineHeight: 1.03)
            .foregroundStyle(T.ink)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }
}

/// Body paragraph.
struct Para: View {
    let text: String
    var size: CGFloat = 16
    var color: Color = T.body
    var body: some View {
        Text(text)
            .face(.sans, size, lineHeight: 1.5)
            .foregroundStyle(color)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// A section that starts with a hairline and a mono kicker.
struct RuledSection<Content: View>: View {
    let title: String
    var titleColor: Color = T.muted
    var spacing: CGFloat = 10
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(title).kicker(titleColor).accessibilityAddTraits(.isHeader)
            content
        }
        .padding(.top, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .top) { Rectangle().fill(T.line).frame(height: 1) }
    }
}

/// A list item with a small circular glyph, used for failures (✕), checks (✓), annotations (✎) and review questions (?).
struct GlyphItem: View {
    let glyph: String
    let color: Color
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(glyph)
                .font(.system(size: 12))
                .foregroundStyle(color)
                .frame(width: 22, height: 22)
                .overlay(Circle().strokeBorder(color, lineWidth: 1))
                .padding(.top, 1)
                .accessibilityHidden(true)
            Text(text).face(.sans, 16, lineHeight: 1.45).foregroundStyle(T.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// Pass / fail pill used in demos.
struct PassPill: View {
    let ok: Bool
    let text: String
    var body: some View {
        Text((ok ? "✓ " : "✕ ") + text)
            .face(.sansBold, 14)
            .foregroundStyle(ok ? T.onInk : T.ink)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(Capsule().fill(ok ? T.ink : Color.clear))
            .accessibilityLabel((ok ? "Passes " : "Fails ") + text)
    }
}

/// The knowledge × scope matrix with "You" marked.
struct MatrixView: View {
    let level: String
    let role: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(["Fluent", "Working", "New"], id: \.self) { l in
                HStack(spacing: 4) {
                    Text(l).face(.sans, 13).foregroundStyle(T.muted).lineLimit(1).fixedSize().frame(width: 58, alignment: .leading)
                    ForEach(Library.roles) { r in
                        let on = l == level && r.id == role
                        RoundedRectangle(cornerRadius: 10)
                            .fill(on ? Tint.accent.color : T.chip)
                            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(on ? Tint.accent.color : T.line, lineWidth: 1))
                            .overlay { if on { Text("You").face(.sansBold, 14).foregroundStyle(T.bg) } }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                }
            }
            HStack(spacing: 4) {
                Color.clear.frame(width: 58, height: 1)
                ForEach(Library.roles) { r in
                    Text(r.id).face(.sans, 13).foregroundStyle(T.muted).lineLimit(1).minimumScaleFactor(0.7).frame(maxWidth: .infinity)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Matrix of knowledge by scope. You are at \(level) knowledge, \(role) scope.")
    }
}

/// Segmented progress (placement and practice).
struct Segments: View {
    let colors: [Color]
    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(colors.enumerated()), id: \.offset) { _, c in
                RoundedRectangle(cornerRadius: 2).fill(c).frame(height: 4).frame(maxWidth: .infinity)
            }
        }
        .accessibilityHidden(true)
    }
}

/// Answer row used by quick checks, placement and practice.
struct AnswerRow<Leading: View>: View {
    let title: String
    let picked: Bool
    let answered: Bool
    let right: Bool
    var markRight = "✓"
    var markWrong = "✕"
    var minHeight: CGFloat = 54
    @ViewBuilder var leading: Leading
    let action: () -> Void

    var body: some View {
        let border: Color = answered && right ? T.green : picked ? T.rust : T.line2
        let mark = answered ? (right ? markRight : picked ? markWrong : "") : ""
        Button(action: action) {
            HStack(spacing: 14) {
                leading
                Text(title).face(.sans, 16, lineHeight: 1.35).foregroundStyle(T.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                if !mark.isEmpty {
                    Text(mark).face(.sansBold, 14).foregroundStyle(right ? T.green : T.rust)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .frame(minHeight: minHeight)
            .background(RoundedRectangle(cornerRadius: 17).fill(answered && right ? Tint.green.color.opacity(0.1) : Color.clear))
            .overlay(RoundedRectangle(cornerRadius: 17).strokeBorder(border, lineWidth: 1))
            .contentShape(RoundedRectangle(cornerRadius: 17))
        }
        .buttonStyle(PressStyle())
        .disabled(answered)
        .accessibilityAddTraits(picked ? [.isSelected] : [])
        .accessibilityHint(answered ? (right ? "Correct answer" : picked ? "Your answer, incorrect" : "") : "")
    }
}

extension AnswerRow where Leading == EmptyView {
    init(title: String, picked: Bool, answered: Bool, right: Bool, markRight: String = "✓", markWrong: String = "✕",
         minHeight: CGFloat = 54, action: @escaping () -> Void) {
        self.init(title: title, picked: picked, answered: answered, right: right, markRight: markRight,
                  markWrong: markWrong, minHeight: minHeight, leading: { EmptyView() }, action: action)
    }
}

/// Card surface.
extension View {
    func card(radius: CGFloat = 24, padding: CGFloat = 22) -> some View {
        self.padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: radius).fill(T.card))
            .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(T.line, lineWidth: 1))
    }
}
