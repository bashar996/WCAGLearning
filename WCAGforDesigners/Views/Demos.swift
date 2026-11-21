import SwiftUI
import Foundation

/// WCAG contrast maths, as in the prototype.
enum ContrastMath {
    static func luminance(_ rgb: UInt32) -> Double {
        let ch = [Double((rgb >> 16) & 0xFF), Double((rgb >> 8) & 0xFF), Double(rgb & 0xFF)].map { v -> Double in
            let s = v / 255
            return s <= 0.03928 ? s / 12.92 : pow((s + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * ch[0] + 0.7152 * ch[1] + 0.0722 * ch[2]
    }

    static func ratio(_ a: UInt32, _ b: UInt32) -> Double {
        let x = luminance(a), y = luminance(b)
        return (max(x, y) + 0.05) / (min(x, y) + 0.05)
    }

    /// Never round up: 4.49:1 fails.
    static func format(_ r: Double) -> String { String(format: "%.2f:1", floor(r * 100) / 100) }

    static func gray(_ v: Int) -> UInt32 { let c = UInt32(max(0, min(255, v))); return c << 16 | c << 8 | c }
    static func hex(_ rgb: UInt32) -> String { String(format: "#%06X", rgb) }
}

// MARK: - 1.4.3 Contrast

struct ContrastDemo: View {
    @Environment(AppStore.self) var store

    var body: some View {
        let g = ContrastMath.gray(store.contrastGray)
        let fg = Color(rgb: g)
        let r = ContrastMath.ratio(g, 0xFFFFFF)
        let hint: String = r >= 4.5
            ? (store.contrastGray == 118 ? "That’s #767676 — the lightest gray that passes on white."
               : r >= 7 ? "Passes AAA too (7:1, criterion 1.4.6)." : "Passes AA for all text. Notice how the particles hold up too.")
            : r >= 3 ? "OK for large text only. Headlines yes; body copy no." : "Fails for all text. Drag toward darker."

        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .bottomLeading) {
                ParticleView(kind: .contrast, seed: 5, options: ParticleOptions(fg: fg))
                VStack(alignment: .leading, spacing: 6) {
                    Text("Can you read this?").face(.serif, 34, lineHeight: 1)
                    Text("Body text at 16px, the size most of your interface uses.").face(.sans, 16, lineHeight: 1.4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(fg)
                .padding(22)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .environment(\.colorScheme, .light)

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(ContrastMath.format(r)).face(.serif, 54).foregroundStyle(T.ink).contentTransition(.numericText())
                    Text("\(ContrastMath.hex(g)) on #FFFFFF").face(.mono, 13).foregroundStyle(T.muted)
                }
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 6) {
                    PassPill(ok: r >= 4.5, text: "Body text")
                    PassPill(ok: r >= 3, text: "Large text")
                }
            }

            Slider(value: Binding(get: { Double(store.contrastGray) }, set: { store.contrastGray = Int($0.rounded()) }),
                   in: 40...215, step: 1)
                .frame(minHeight: 44)
                .accessibilityLabel("Text lightness")
                .accessibilityValue("\(ContrastMath.hex(g)), \(ContrastMath.format(r))")
            HStack {
                Text("Darker text")
                Spacer()
                Text("Lighter text")
            }
            .face(.sans, 14).foregroundStyle(T.muted)
            .accessibilityHidden(true)
            Para(text: hint, size: 15)
        }
    }
}

// MARK: - 1.4.1 Use of colour

struct ColorDemo: View {
    @Environment(AppStore.self) var store

    private let modes = [("none", "Typical"), ("deutan", "Deuteranopia"), ("protan", "Protanopia"), ("achro", "Monochrome")]

    var body: some View {
        let hint = store.shapes ? "Now switch the simulation on and off. The answer — 12 — survives every mode."
            : store.cvd == "none" ? "Easy in typical vision. Now try Deuteranopia, the most common type."
            : "Hard to count, isn’t it? Color alone just failed. Add a shape."
        VStack(alignment: .leading, spacing: 14) {
            Text("Each particle is a project. Red ones are at risk. **How many are there?**")
                .face(.sans, 16, lineHeight: 1.45).foregroundStyle(T.ink)
                .fixedSize(horizontal: false, vertical: true)
            ParticleView(kind: .color, seed: 9, options: ParticleOptions(shapes: store.shapes, cvd: store.cvd))
                .frame(height: 210)
                .background(T.card)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(T.line, lineWidth: 1))
            FlowLayout(spacing: 8, lineSpacing: 8) {
                ForEach(0..<modes.count, id: \.self) { i in
                    let id = modes[i].0, label = modes[i].1
                    Chip(label: label, on: store.cvd == id, height: 40) { store.cvd = id }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Simulate vision")
            Button(store.shapes ? "✓ Shape added: at-risk = triangle" : "Add a second cue: shape") { store.shapes.toggle() }
                .buttonStyle(PillButtonStyle(fill: store.shapes ? T.ink : nil))
                .accessibilityAddTraits(store.shapes ? [.isSelected] : [])
            Para(text: hint, size: 15)
        }
    }
}

// MARK: - 2.5.8 Target size

struct TapsDemo: View {
    let tint: Tint
    @Environment(AppStore.self) var store

    var body: some View {
        let s = store.targetSize
        let hit = Int((pow(erf(s / (2 * 2.0.squareRoot() * 9)), 2) * 100).rounded())
        let hint = s < 24 ? "Below the AA minimum — roughly every other tap misses."
            : s < 44 ? "Meets AA. Most taps land, but plenty still miss." : "Comfortable. Almost every tap lands."
        VStack(alignment: .leading, spacing: 14) {
            Text("Simulated taps with a natural finger spread, at real size. Filled dots hit; hollow rings miss.")
                .face(.sans, 16, lineHeight: 1.45).foregroundStyle(T.ink)
                .fixedSize(horizontal: false, vertical: true)
            ParticleView(kind: .taps, seed: 21, options: ParticleOptions(tint: tint, size: s))
                .frame(height: 200)
                .background(T.card)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(T.line, lineWidth: 1))
            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(hit)%").face(.serif, 54).foregroundStyle(T.ink).contentTransition(.numericText())
                    Text("of taps land on a \(Int(s))px target").face(.sans, 14).foregroundStyle(T.muted)
                }
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 6) {
                    PassPill(ok: s >= 24, text: "2.5.8 · 24px")
                    PassPill(ok: s >= 44, text: "2.5.5 · 44px")
                }
            }
            Slider(value: Binding(get: { store.targetSize }, set: { store.targetSize = $0 }), in: 12...56, step: 2)
                .frame(minHeight: 44)
                .accessibilityLabel("Target size in pixels")
                .accessibilityValue("\(Int(s)) pixels, \(hit) percent of taps land")
            Para(text: "The dashed circle is the 24px minimum. " + hint, size: 15)
        }
    }
}

// MARK: - 2.3.3 Animation from interactions

struct MotionDemo: View {
    let tint: Tint
    @Environment(AppStore.self) var store

    var body: some View {
        let on = store.demoReduced
        VStack(alignment: .leading, spacing: 14) {
            Text("Parallax like this is pretty for most people — and can bring on dizziness or nausea for others.")
                .face(.sans, 16, lineHeight: 1.45).foregroundStyle(T.ink)
                .fixedSize(horizontal: false, vertical: true)
            ParticleView(kind: .motion, seed: 33, options: ParticleOptions(tint: tint, reduced: on))
                .frame(height: 200)
                .background(T.card)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(T.line, lineWidth: 1))
            Button { store.demoReduced.toggle() } label: {
                HStack {
                    Text("Reduce motion").face(.sansMedium, 17).foregroundStyle(T.ink)
                    Spacer()
                    DesignSwitch(on: on, tint: tint.color)
                }
                .padding(.horizontal, 18)
                .frame(minHeight: 60)
                .background(RoundedRectangle(cornerRadius: 18).fill(T.card))
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(T.line2, lineWidth: 1))
            }
            .buttonStyle(PressStyle())
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isToggle)
            .accessibilityValue(on ? "On" : "Off")
            Para(text: on ? "Still there, still beautiful — just not moving. That’s the whole ask."
                 : "Turn it on. This is what honoring the system setting looks like.", size: 15)
        }
    }
}
