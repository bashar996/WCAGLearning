import SwiftUI

/// Demo-only fonts: fixed sizes, so the demo shows the effect it is teaching rather than following Dynamic Type.
private func demoFont(_ face: Face, _ size: CGFloat) -> Font { Font.custom(face.postScriptName, fixedSize: size) }

/// A labelled option chip that toggles on and off (used where several cues can be combined).
private struct ToggleChip: View {
    let label: String
    let on: Bool
    var enabled = true
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text((on ? "✓ " : "") + label)
                .face(on ? .sansBold : .sansMedium, 14)
                .foregroundStyle(on ? T.onInk : T.ink)
                .padding(.horizontal, 14)
                .frame(minHeight: 40)
                .background(Capsule().fill(on ? T.ink : Color.clear))
                .overlay(Capsule().strokeBorder(on ? T.ink : T.mute2, lineWidth: 1))
                .opacity(enabled ? 1 : 0.6)
                .contentShape(Capsule())
        }
        .buttonStyle(PressStyle())
        .disabled(!enabled)
        .accessibilityAddTraits(on ? [.isSelected] : [])
    }
}

// MARK: - 2.4.13 Focus appearance

struct FocusDemo: View {
    @State var thickness: Double = 1
    @State var ringIndex = 0
    @State var surfaceIndex = 0

    private let surfaces: [(name: String, rgb: UInt32)] = [("White", 0xFFFFFF), ("Paper", 0xEDE8DE), ("Ink", 0x1F1D1A), ("Brand blue", 0x2F4A63)]
    /// nil = two-tone ring: a white band inside an ink band.
    private let rings: [(name: String, rgb: UInt32?)] = [("Light gray", 0xC4BBA9), ("Slate blue", 0x2F4A63), ("Ink", 0x1F1D1A), ("White", 0xFFFFFF), ("Two-tone", nil)]

    var body: some View {
        let surface = surfaces[surfaceIndex].rgb
        let ring = rings[ringIndex].rgb
        // The ring sits outside the button, so the pixels it changes were the surface before focus.
        let change: Double = ring.map { ContrastMath.ratio($0, surface) }
            ?? max(ContrastMath.ratio(0xFFFFFF, surface), ContrastMath.ratio(0x1F1D1A, surface))
        let sizeOK = thickness >= 2
        let changeOK = change >= 3
        let hint: String = sizeOK && changeOK
            ? (ring == nil ? "A two-tone ring passes on every surface here. That is why design systems like it." : "Passes 2.4.13. Now try another surface: does the same ring still hold up?")
            : !sizeOK && !changeOK ? "Too thin and too faint. Visible enough for 2.4.7, maybe, but not for 2.4.13."
            : !sizeOK ? "The colour is strong enough, but the ring is thinner than a 2px perimeter. Drag it thicker."
            : "Thick enough, but the ring barely differs from the surface behind it. Pick a colour with 3:1 or more."

        VStack(alignment: .leading, spacing: 14) {
            Text("Tune the focus ring until it passes. The ring is drawn outside the button, so it is compared with the surface it covers.")
                .face(.sans, 16, lineHeight: 1.45).foregroundStyle(T.ink)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 0) {
                sample(focused: false, surface: surface, ring: ring)
                sample(focused: true, surface: surface, ring: ring)
            }
            .frame(height: 150)
            .background(Color(rgb: surface))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(T.line, lineWidth: 1))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("A button before and after focus, on \(surfaces[surfaceIndex].name). Ring: \(rings[ringIndex].name), \(String(format: "%.1f", thickness)) pixels.")

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(ContrastMath.format(change)).face(.serif, 54).foregroundStyle(T.ink).contentTransition(.numericText())
                    Text("change when focused").face(.sans, 14).foregroundStyle(T.muted)
                }
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 6) {
                    PassPill(ok: sizeOK, text: "Size · 2px")
                    PassPill(ok: changeOK, text: "Change · 3:1")
                }
            }

            Slider(value: $thickness, in: 1...4, step: 0.5)
                .frame(minHeight: 44)
                .accessibilityLabel("Ring thickness")
                .accessibilityValue("\(String(format: "%.1f", thickness)) pixels")
            HStack {
                Text("Ring thickness")
                Spacer()
                Text("\(String(format: "%.1f", thickness)) px")
            }
            .face(.sans, 14).foregroundStyle(T.muted)

            chooser("RING COLOUR", names: rings.map(\.name), selected: $ringIndex)
            chooser("SURFACE", names: surfaces.map(\.name), selected: $surfaceIndex)
            Para(text: hint, size: 15)
        }
    }

    private func sample(focused: Bool, surface: UInt32, ring: UInt32?) -> some View {
        let dark = ContrastMath.luminance(surface) < 0.2
        let fill = dark ? Color.white : Color(rgb: 0x1F1D1A)
        let label = dark ? Color(rgb: 0x1F1D1A) : Color.white
        let t = CGFloat(thickness), offset: CGFloat = 3
        return VStack(spacing: 10) {
            Text("Continue")
                .font(demoFont(.sansBold, 15))
                .foregroundStyle(label)
                .padding(.horizontal, 22)
                .frame(height: 44)
                .background(Capsule().fill(fill))
                .overlay {
                    if focused {
                        if let ring {
                            Capsule().inset(by: -(offset + t / 2)).stroke(Color(rgb: ring), lineWidth: t)
                        } else {
                            ZStack {
                                Capsule().inset(by: -(offset + t / 2)).stroke(Color.white, lineWidth: t)
                                Capsule().inset(by: -(offset + t + t / 2)).stroke(Color(rgb: 0x1F1D1A), lineWidth: t)
                            }
                        }
                    }
                }
            Text(focused ? "FOCUSED" : "UNFOCUSED")
                .font(demoFont(.mono, 11))
                .tracking(1)
                .foregroundStyle(dark ? Color.white.opacity(0.7) : Color(rgb: 0x6B665D))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func chooser(_ title: String, names: [String], selected: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).kicker(size: 12)
            FlowLayout(spacing: 8, lineSpacing: 8) {
                ForEach(names.indices, id: \.self) { i in
                    Chip(label: names[i], on: selected.wrappedValue == i, height: 40) { selected.wrappedValue = i }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(title.capitalized)
        }
    }
}

// MARK: - 1.4.4 Resize text

struct ResizeDemo: View {
    @State var scale: Double = 1
    @State var fixed = true
    @State var natural: CGFloat = 0

    private let boxHeight: CGFloat = 150

    var body: some View {
        let s = CGFloat(scale)
        let lost = fixed && natural > boxHeight + 0.5
        let pct = Int((scale * 100).rounded())
        let hint: String = lost
            ? "The card kept its fixed height, so the text grew out of it and got cut off. Switch to “Hugs content”."
            : fixed && scale < 1.3 ? "Fine at this size. Now drag toward 200%, the size this rule tests."
            : fixed ? "Still fits, just. Longer words or a translation would break it."
            : "The card grows with its text and the button label wraps. Nothing is lost at 200%."

        VStack(alignment: .leading, spacing: 14) {
            Text("A card from a checkout. Enlarge the text and watch what the layout does with it.")
                .face(.sans, 16, lineHeight: 1.45).foregroundStyle(T.ink)
                .fixedSize(horizontal: false, vertical: true)

            ZStack(alignment: .topLeading) {
                card(s)
                    .fixedSize(horizontal: false, vertical: true)
                    .background {
                        GeometryReader { g in
                            Color.clear
                                .onAppear { natural = g.size.height }
                                .onChange(of: g.size.height) { _, h in natural = h }
                        }
                    }
                    .frame(height: fixed ? boxHeight : nil, alignment: .top)
                    .clipped()
                    .overlay(alignment: .bottom) {
                        if lost {
                            Rectangle().fill(T.rust).frame(height: 2).accessibilityHidden(true)
                        }
                    }
            }
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(T.line, lineWidth: 1))
            .animation(.easeOut(duration: 0.15), value: fixed)
            .environment(\.colorScheme, .light)

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(pct)%").face(.serif, 54).foregroundStyle(T.ink).contentTransition(.numericText())
                    Text("text size").face(.sans, 14).foregroundStyle(T.muted)
                }
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 6) {
                    PassPill(ok: !lost, text: "Nothing cut off")
                    PassPill(ok: scale >= 1.95 && !lost, text: "Works at 200%")
                }
            }

            Slider(value: $scale, in: 1...2, step: 0.1)
                .frame(minHeight: 44)
                .accessibilityLabel("Text size")
                .accessibilityValue("\(pct) percent" + (lost ? ", content cut off" : ""))
            HStack(spacing: 8) {
                Chip(label: "Fixed height", on: fixed, height: 40) { fixed = true }
                Chip(label: "Hugs content", on: !fixed, height: 40) { fixed = false }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Card layout")
            Para(text: hint, size: 15)
        }
    }

    private func card(_ s: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8 * s) {
            Text("Your order").font(demoFont(.serif, 22 * s)).foregroundStyle(Color(rgb: 0x1F1D1A))
            Text("2 items · Delivery on Thursday").font(demoFont(.sans, 15 * s)).foregroundStyle(Color(rgb: 0x4A463F))
                .fixedSize(horizontal: false, vertical: true)
            Text("Continue to payment")
                .font(demoFont(.sansBold, 15 * s))
                .foregroundStyle(Color.white)
                .lineLimit(fixed ? 1 : nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: !fixed)
                .padding(.horizontal, 16).padding(.vertical, 10)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Capsule().fill(Color(rgb: 0x2F4A63)))
                .padding(.top, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - 3.3.1 Error identification

struct FormErrorDemo: View {
    @State var icon = false
    @State var message = false
    @State var gray = false

    var body: some View {
        let rust = Color(rgb: 0xB23A22)
        let spoken: String = message
            ? "“Email, alex@studio, invalid entry. Enter an email address, like name@studio.com.”"
            : icon ? "“Email, alex@studio. Error.” It says something is wrong, but not what."
            : "“Email, alex@studio.” Nothing at all about the error."
        let hint: String = message
            ? "The message names the problem and the fix, so it works without colour and without sight."
            : icon ? "The icon helps people who cannot see red, but nobody can tell from it what is wrong. Add a message."
            : "Only the border changed. Switch on grayscale: can you still tell this field has an error?"

        VStack(alignment: .leading, spacing: 14) {
            Text("Someone submitted this form with a typo in their email. Add cues until everyone can tell what went wrong.")
                .face(.sans, 16, lineHeight: 1.45).foregroundStyle(T.ink)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                Text("Email").font(demoFont(.sansBold, 15)).foregroundStyle(Color(rgb: 0x1F1D1A))
                HStack {
                    Text("alex@studio").font(demoFont(.sans, 16)).foregroundStyle(Color(rgb: 0x1F1D1A))
                    Spacer()
                    if icon {
                        Image(systemName: "exclamationmark.circle.fill").foregroundStyle(rust).font(.system(size: 18))
                    }
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(rust, lineWidth: 2))
                if message {
                    HStack(alignment: .top, spacing: 6) {
                        Text("✕")
                        Text("Enter an email address, like name@studio.com")
                    }
                    .font(demoFont(.sansBold, 14))
                    .foregroundStyle(rust)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color(rgb: 0xFBF9F4)))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(T.line, lineWidth: 1))
            .grayscale(gray ? 1 : 0)
            .environment(\.colorScheme, .light)
            .animation(.easeOut(duration: 0.15), value: icon)
            .animation(.easeOut(duration: 0.15), value: message)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Sample email field showing alex@studio" + (icon ? ", with an error icon" : "") + (message ? ", with the message: Enter an email address, like name@studio.com" : ", with only a red border"))

            FlowLayout(spacing: 8, lineSpacing: 8) {
                ToggleChip(label: "Red border", on: true, enabled: false) {}
                ToggleChip(label: "Icon", on: icon) { icon.toggle() }
                ToggleChip(label: "Text message", on: message) { message.toggle() }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Error cues")

            Button { gray.toggle() } label: {
                HStack {
                    Text("View in grayscale").face(.sansMedium, 17).foregroundStyle(T.ink)
                    Spacer()
                    DesignSwitch(on: gray)
                }
                .padding(.horizontal, 18)
                .frame(minHeight: 56)
                .background(RoundedRectangle(cornerRadius: 18).fill(T.card))
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(T.line2, lineWidth: 1))
            }
            .buttonStyle(PressStyle())
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isToggle)
            .accessibilityValue(gray ? "On" : "Off")

            VStack(alignment: .leading, spacing: 6) {
                Text("A SCREEN READER SAYS").kicker(size: 12)
                Text(spoken).face(.serif, 20, lineHeight: 1.25).foregroundStyle(T.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 6) {
                PassPill(ok: icon || message, text: "1.4.1 · not colour alone")
                PassPill(ok: message, text: "3.3.1 · in text")
            }
            Para(text: hint, size: 15)
        }
    }
}

// MARK: - 1.3.2 Meaningful sequence

struct ReadingOrderDemo: View {
    @State var byRows = true
    @State var playing: Int? = nil
    @State var task: Task<Void, Never>? = nil

    private let steps = ["Download the app", "Create an account", "Verify your email", "Pick your level", "Choose a path", "Start lesson one"]

    /// Visual step indexes in the order the code presents them.
    private var codeOrder: [Int] { byRows ? [0, 3, 1, 4, 2, 5] : [0, 1, 2, 3, 4, 5] }

    var body: some View {
        let order = codeOrder
        VStack(alignment: .leading, spacing: 14) {
            Text("Six setup steps, laid out in two columns. The small badge shows the order the code gives a screen reader.")
                .face(.sans, 16, lineHeight: 1.45).foregroundStyle(T.ink)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 10) {
                VStack(spacing: 10) { ForEach(0..<3, id: \.self) { tile($0, order: order) } }
                VStack(spacing: 10) { ForEach(3..<6, id: \.self) { tile($0, order: order) } }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 22).fill(T.card))
            .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(T.line, lineWidth: 1))
            // VoiceOver really follows the chosen code order here, so the demo can be heard, not just seen.
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Setup steps")

            HStack(spacing: 8) {
                Chip(label: "Code across rows", on: byRows, height: 40) { setRows(true) }
                Chip(label: "Code down columns", on: !byRows, height: 40) { setRows(false) }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Code order")

            Button(playing == nil ? "▶ Hear the reading order" : "■ Stop") { togglePlay() }
                .buttonStyle(PillButtonStyle(fill: playing == nil ? nil : T.ink))

            VStack(alignment: .leading, spacing: 6) {
                Text("A SCREEN READER SAYS").kicker(size: 12)
                Text(order.map { "\($0 + 1). \(steps[$0])" }.joined(separator: " → "))
                    .face(.sans, 15, lineHeight: 1.45).foregroundStyle(T.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }

            PassPill(ok: !byRows, text: "Order keeps its meaning")
            Para(text: byRows
                 ? "The columns look right, but the code runs across the rows, so people hear step 4 before step 2. Annotate the reading order."
                 : "Now the code runs down each column, the same order the steps are meant to be done in. Turn on VoiceOver and swipe through to hear it.",
                 size: 15)
        }
        .onDisappear { task?.cancel() }
    }

    private func tile(_ i: Int, order: [Int]) -> some View {
        let pos = order.firstIndex(of: i) ?? 0
        let active = playing == i
        return HStack(alignment: .top, spacing: 10) {
            Text("\(i + 1)").face(.serif, 30).foregroundStyle(active ? T.onInk : T.ink)
            VStack(alignment: .leading, spacing: 4) {
                Text(steps[i]).face(.sansMedium, 14, lineHeight: 1.3).foregroundStyle(active ? T.onInk : T.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("read #\(pos + 1)").face(.mono, 11).foregroundStyle(active ? T.onInk : (pos == i ? T.green : T.rust))
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 14).fill(active ? T.ink : T.bg))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(T.line, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(i + 1). \(steps[i])")
        .accessibilitySortPriority(Double(6 - pos))
    }

    private func setRows(_ rows: Bool) {
        task?.cancel()
        playing = nil
        byRows = rows
    }

    private func togglePlay() {
        if playing != nil {
            task?.cancel()
            playing = nil
            return
        }
        let order = codeOrder
        task = Task { @MainActor in
            for i in order {
                withAnimation(.easeInOut(duration: 0.15)) { playing = i }
                try? await Task.sleep(nanoseconds: 800_000_000)
                if Task.isCancelled { return }
            }
            withAnimation { playing = nil }
        }
    }
}
