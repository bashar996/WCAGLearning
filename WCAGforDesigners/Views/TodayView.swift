import SwiftUI

struct TodayView: View {
    @Environment(AppStore.self) var store
    @Environment(\.uiScale) var scale

    var body: some View {
        PageSpread {
            overview
        } second: {
            working
        }
    }

    // MARK: Overview page: today's lesson

    private var dateLine: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.dateFormat = "EEE d MMM"
        return f.string(from: store.now).uppercased()
    }

    @ViewBuilder private var overview: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(dateLine).kicker(size: 13, tracking: 0.08)
            (Text("Learn the standard, ")
                + Text("one criterion").font(Fonts.font(.serifItalic, 46, scale: scale)).foregroundStyle(T.accent)
                + Text(" at a time."))
                .font(Fonts.font(.serif, 46, scale: scale))
                .foregroundStyle(T.ink)
                .lineSpacing(-4)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
        }
        FeaturedCard(c: store.featured)
    }

    // MARK: Working page: review, map, path

    @ViewBuilder private var working: some View {
        if !store.due.isEmpty {
            Button { store.startReview() } label: {
                HStack(spacing: 16) {
                    Text("\(store.due.count)").face(.serif, 46).foregroundStyle(T.ink)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Due for review").face(.sansBold, 17).foregroundStyle(T.ink)
                        Text("Dimmed dots on your map. Recall them to keep them lit.")
                            .face(.sans, 14, lineHeight: 1.4).foregroundStyle(T.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "arrow.right").foregroundStyle(T.ink).flipsForRightToLeftLayoutDirection(true)
                }
                .padding(.horizontal, 20).padding(.vertical, 14)
                .frame(minHeight: 76)
                .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(T.ink, lineWidth: 1))
            }
            .buttonStyle(PressStyle())
            .accessibilityElement(children: .combine)
            .accessibilityHint("Opens review in Practice")
        }

        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Your map of WCAG").face(.serif, 30).foregroundStyle(T.ink).accessibilityAddTraits(.isHeader)
                Spacer()
                Text("\(store.learnedCount)/\(WCAG.total)").face(.mono, 14).foregroundStyle(T.muted)
            }
            Para(text: "Each dot is one success criterion. Learn one and it lights up. Tap any dot to read it.", size: 15, color: T.muted)
            WCAGMap()
        }

        PathList()
    }
}

/// "Today's lesson" card with its particle poster.
struct FeaturedCard: View {
    let c: Criterion
    @Environment(AppStore.self) var store

    var body: some View {
        let p = c.principle
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                ParticleView(kind: p.particleKind, seed: c.seed, options: ParticleOptions(tint: p.tint))
                    .frame(height: 220)
                Text("TODAY'S LESSON")
                    .face(.mono, 13, tracking: 0.06)
                    .foregroundStyle(T.ink)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Capsule().fill(T.bg.opacity(0.72)))
                    .padding(16)
            }
            VStack(alignment: .leading, spacing: 12) {
                Text("\(c.num) · Level \(c.level.rawValue) · \(p.name)")
                    .face(.mono, 14, tracking: 0.04).foregroundStyle(p.tint.color)
                Text(c.title).face(.serif, 38, lineHeight: 1).foregroundStyle(T.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Para(text: c.summary)
                HStack(spacing: 14) {
                    Button("Begin lesson") { store.openCriterion(c.num) }
                        .buttonStyle(PillButtonStyle(fill: p.tint.color, onFill: T.bg))
                        .fixedSize()
                    Text(c.lesson?.meta ?? "3 min read").face(.sans, 14).foregroundStyle(T.muted)
                }
                .padding(.top, 6)
            }
            .padding(.horizontal, 22).padding(.top, 4).padding(.bottom, 22)
        }
        .background(T.card)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).strokeBorder(T.line, lineWidth: 1))
    }
}

/// All 86 criteria as dots, grouped by principle. Learned dots glow; due ones dim; today's lesson is ringed.
struct WCAGMap: View {
    @Environment(AppStore.self) var store

    var body: some View {
        let due = Set(store.due)
        let featured = store.featured.num
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Library.principles) { p in
                let list = WCAG.criteria(in: p)
                let tint = p.tint.color
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("\(p.id) · \(p.name)").face(.mono, 13, tracking: 0.06).foregroundStyle(tint)
                        Spacer()
                        Text("\(list.filter { store.isLearned($0.num) }.count)/\(list.count)").face(.mono, 13).foregroundStyle(T.muted)
                    }
                    .padding(.horizontal, 4)
                    FlowLayout(spacing: 2, lineSpacing: 2) {
                        ForEach(list) { c in
                            let on = store.isLearned(c.num), f = c.num == featured, dim = on && due.contains(c.num)
                            let fillColor: Color = dim ? tint.opacity(0.4) : (on ? tint : (f ? Color.clear : T.mute2))
                            Button { store.openCriterion(c.num) } label: {
                                ZStack {
                                    Circle()
                                        .fill(fillColor)
                                        .overlay { if f && !on { Circle().strokeBorder(tint, lineWidth: 2) } }
                                        .frame(width: on || f ? 12 : 6, height: on || f ? 12 : 6)
                                        .shadow(color: on && !dim ? tint.opacity(0.7) : .clear, radius: 5)
                                }
                                .frame(width: 24, height: 24)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PressStyle())
                            .accessibilityLabel("\(c.num) \(c.title)" + (dim ? ", due for review" : on ? ", learned" : ""))
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 18)
        .background(RoundedRectangle(cornerRadius: 24).fill(T.card))
        .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(T.line, lineWidth: 1))
    }
}

/// Your current path, with the next lesson marked.
struct PathList: View {
    @Environment(AppStore.self) var store

    var body: some View {
        let path = store.path
        let next = path.list.first { !store.isLearned($0) }
        VStack(alignment: .leading, spacing: 14) {
            Text("YOUR PATH").kicker()
            Text(path.name).face(.serif, 30).foregroundStyle(T.ink).accessibilityAddTraits(.isHeader)
            Para(text: path.desc, size: 15, color: T.muted)
            VStack(spacing: 0) {
                ForEach(Array(path.list.enumerated()), id: \.element) { i, n in
                    let x = WCAG.criterion(n), on = store.isLearned(n), isNext = n == next
                    Button { store.openCriterion(n) } label: {
                        HStack(spacing: 14) {
                            Text(String(format: "%02d", i + 1)).face(.mono, 13).foregroundStyle(T.muted).frame(width: 26, alignment: .leading)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(n) · \(x.level.rawValue)").face(.mono, 13).foregroundStyle(x.principle.tint.color)
                                Text(x.title).face(.sansMedium, 17).foregroundStyle(T.ink).multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            if isNext {
                                Text("Next").face(.sansBold, 14).foregroundStyle(T.onInk)
                                    .padding(.horizontal, 10).padding(.vertical, 4)
                                    .background(Capsule().fill(T.ink))
                            } else if on {
                                Text("✓ Learned").face(.sansBold, 14).foregroundStyle(x.principle.tint.color)
                                    .padding(.horizontal, 10).padding(.vertical, 4)
                            }
                        }
                        .padding(.horizontal, 8).padding(.vertical, 10)
                        .frame(minHeight: 64)
                        .overlay(alignment: .bottom) { Rectangle().fill(T.line).frame(height: 1) }
                    }
                    .buttonStyle(PressStyle())
                    .accessibilityElement(children: .combine)
                }
            }
            .overlay(alignment: .top) { Rectangle().fill(T.line).frame(height: 1) }
        }
    }
}
