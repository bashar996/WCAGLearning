import SwiftUI

struct YouView: View {
    @Environment(AppStore.self) var store
    @State var sheet: AccountSheet?

    var body: some View {
        PageSpread(spacing: 28) {
            VStack(alignment: .leading, spacing: 10) {
                Headline(text: "You")
                Para(text: "\(store.level) knowledge, \(store.role) scope. Lessons open on “\(store.defaultDepth.label)”.")
                accountCard.padding(.top, 8)
            }
            MatrixView(level: store.level, role: store.role)
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    (Text("\(store.learnedCount)") + Text(" / \(WCAG.total)").foregroundStyle(T.muted))
                        .face(.serif, 40).foregroundStyle(T.ink)
                    Text("criteria learned").face(.sans, 14).foregroundStyle(T.muted)
                }
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(store.due.count)").face(.serif, 40).foregroundStyle(T.ink)
                    Text("due for review").face(.sans, 14).foregroundStyle(T.muted)
                }
                .padding(.vertical, 14).padding(.leading, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .leading) { Rectangle().fill(T.line).frame(width: 1) }
                .accessibilityElement(children: .combine)
            }
            .overlay(alignment: .top) { Rectangle().fill(T.line).frame(height: 1) }
            .overlay(alignment: .bottom) { Rectangle().fill(T.line).frame(height: 1) }
        } second: {
            VStack(alignment: .leading, spacing: 12) {
                Text("YOUR SCOPE").kicker().accessibilityAddTraits(.isHeader)
                FlowLayout(spacing: 8, lineSpacing: 8) {
                    ForEach(Library.roles) { r in
                        Chip(label: r.id, on: store.role == r.id) { store.setRole(r.id) }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Your scope")
                Text((Library.roles.first { $0.id == store.role }?.desc ?? "") + " Practice task: \(store.roleTask.name).")
                    .face(.sans, 14, lineHeight: 1.45).foregroundStyle(T.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Retake placement") { store.retakePlacement() }
                    .buttonStyle(PillButtonStyle(size: 15))
            }
            VStack(alignment: .leading, spacing: 12) {
                Text("READING AND MOTION").kicker().accessibilityAddTraits(.isHeader)
                settingRow("Appearance") {
                    ForEach(ThemeChoice.allCases, id: \.self) { t in
                        Chip(label: t.label, on: store.theme == t) { store.setTheme(t) }
                    }
                }
                settingRow("Text size") {
                    ForEach([1.0, 1.15, 1.3], id: \.self) { v in
                        Chip(label: "\(Int((v * 100).rounded()))%", on: abs(store.textScale - v) < 0.01) { store.setTextScale(v) }
                    }
                }
                VStack(spacing: 0) {
                    SwitchRow(label: "Reduce motion", desc: "Posters and demos hold still.", on: store.still) { store.toggleStill() }
                    SwitchRow(label: "Hide particles", desc: "Flat color in place of every poster.", on: store.noParticles) { store.toggleNoParticles() }
                    SwitchRow(label: "Mirror layout", desc: "Right-to-left preview, for Arabic, Hebrew, Persian and Urdu.", on: store.mirror) { store.toggleMirror() }
                }
                .overlay(alignment: .top) { Rectangle().fill(T.line).frame(height: 1) }
                Para(text: "Text also follows the size you set in iOS Settings → Display & Brightness → Text Size. Reduce motion also follows the system setting.", size: 14, color: T.muted)
            }
        }
        .sheet(item: $sheet) { s in
            AccountSheetView(initial: s)
                .environment(store)
        }
    }

    private var accountCard: some View {
        let a = store.account
        let name = a?.name ?? "Guest"
        return HStack(spacing: 14) {
            Text(a?.initials ?? "G")
                .face(.serifItalic, 24)
                .foregroundStyle(T.bg)
                .frame(width: 52, height: 52)
                .background(Circle().fill(T.accent))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(name).face(.sansBold, 18).foregroundStyle(T.ink)
                Text(a.map { $0.email + ($0.via != "Email" ? " · \($0.via)" : "") } ?? "Not signed in. Progress stays on this device.")
                    .face(.sans, 14, lineHeight: 1.4).foregroundStyle(T.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if a != nil {
                Button("Profile") { sheet = .profile }
                    .buttonStyle(PillButtonStyle(border: T.mute2, height: 44, size: 14)).fixedSize()
            } else {
                Button("Log in") { sheet = .login }
                    .buttonStyle(PillButtonStyle(height: 44, size: 14)).fixedSize()
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 22).fill(T.card))
        .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(T.line, lineWidth: 1))
    }

    private func settingRow<C: View>(_ label: String, @ViewBuilder chips: () -> C) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                Text(label).face(.sansMedium, 17).foregroundStyle(T.ink)
                Spacer(minLength: 8)
                HStack(spacing: 6) { chips() }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(label).face(.sansMedium, 17).foregroundStyle(T.ink)
                FlowLayout(spacing: 6, lineSpacing: 6) { chips() }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(label)
    }
}
