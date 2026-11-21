import SwiftUI

/// A success criterion. Open: a two-page spread — read on the left; demo, quick check and actions on the right,
/// with the demo pinned at every depth. Closed: one column, with the demo shown under "See it".
struct CriterionView: View {
    let num: String
    @Environment(AppStore.self) var store
    @Environment(\.layout) var layout

    var body: some View {
        let x = WCAG.criterion(num)
        PageSpread(resetID: num, spacing: 24) {
            reading(x)
        } second: {
            working(x)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                let on = store.isLearned(num)
                Button { store.toggleLearned(num) } label: {
                    Image(systemName: on ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(on ? x.principle.tint.color : T.ink)
                }
                .accessibilityLabel(on ? "Learned — lit on your map" : "Mark as learned")
            }
        }
        .sensoryFeedback(.success, trigger: store.learnedCount) { old, new in new > old }
    }

    // MARK: Reading page

    @ViewBuilder private func reading(_ x: Criterion) -> some View {
        let p = x.principle
        ZStack(alignment: .bottomLeading) {
            ParticleView(kind: p.particleKind, seed: x.seed, options: ParticleOptions(tint: p.tint))
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 28))
            Text(x.num)
                .face(.serif, 96)
                .foregroundStyle(p.tint.color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.leading, 20)
                .padding(.bottom, -14)
                .accessibilityHidden(true)
        }
        .padding(.bottom, 6)

        VStack(alignment: .leading, spacing: 14) {
            Text("SUCCESS CRITERION \(x.num) · \(x.guidelineNum) \(x.guideline.name.uppercased())")
                .kicker(size: 13, tracking: 0.06)
                .fixedSize(horizontal: false, vertical: true)
            Headline(text: x.title, size: 44)
            FlowLayout(spacing: 8, lineSpacing: 8) {
                LevelBadge(level: x.level, prefix: "Level ", height: 30, size: 13)
                Text(x.designerLed ? "Designers lead" : "Mostly dev & content")
                    .face(.sans, 14).foregroundStyle(T.body)
                    .padding(.horizontal, 12).frame(minHeight: 30)
                    .overlay(Capsule().strokeBorder(T.line2, lineWidth: 1))
                if x.isNew {
                    Text("New in 2.2").face(.sansBold, 14).foregroundStyle(T.bg)
                        .padding(.horizontal, 12).frame(minHeight: 30)
                        .background(Capsule().fill(p.tint.color))
                }
            }
            Text(x.summary).face(.sans, 20, lineHeight: 1.45).foregroundStyle(T.ink)
                .fixedSize(horizontal: false, vertical: true)
        }

        if let d = x.lesson {
            DepthPicker()
            DepthContent(x: x, d: d)
        } else {
            RuledSection(title: "PART OF GUIDELINE \(x.guidelineNum)", spacing: 6) {
                Para(text: x.guideline.summary)
            }
            let siblings = WCAG.order.filter { $0 != x.num && WCAG.criterion($0).guidelineNum == x.guidelineNum }.prefix(5)
            if !siblings.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(siblings), id: \.self) { n in
                        let s = WCAG.criterion(n)
                        Button { store.replaceCriterion(n) } label: {
                            HStack(spacing: 12) {
                                Text(n).face(.mono, 14).foregroundStyle(p.tint.color).frame(width: 48, alignment: .leading)
                                Text(s.title).face(.sans, 16).foregroundStyle(T.ink).multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(s.level.rawValue).face(.mono, 12).foregroundStyle(T.muted)
                            }
                            .padding(.vertical, 8).frame(minHeight: 56)
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

    // MARK: Working page

    @ViewBuilder private func working(_ x: Criterion) -> some View {
        let d = x.lesson
        let learned = store.isLearned(x.num)
        let tint = x.principle.tint.color

        if let demo = d?.demo, layout.spread || store.depth == .see {
            VStack(alignment: .leading, spacing: 14) {
                Text("TRY IT").kicker()
                switch demo {
                case .contrast: ContrastDemo()
                case .color: ColorDemo()
                case .taps: TapsDemo(tint: x.principle.tint)
                case .motion: MotionDemo(tint: x.principle.tint)
                }
            }
        }

        if let d {
            QuickCheck(num: x.num, quiz: d.quiz, tint: tint)
        }

        VStack(spacing: 12) {
            Button(learned ? "✓ Learned — lit on your map" : "Mark as learned") { store.toggleLearned(x.num) }
                .buttonStyle(PillButtonStyle(fill: learned ? tint : nil, onFill: T.bg, border: tint, height: 56))
                .accessibilityAddTraits(learned ? [.isSelected] : [])
            HStack(spacing: 10) {
                neighbour(WCAG.neighbour(of: x.num, offset: -1), forward: false)
                neighbour(WCAG.neighbour(of: x.num, offset: 1), forward: true)
            }
        }

        RuledSection(title: "FURTHER READING") {
            reading(link: x.understandingURL, title: "Understanding \(x.num)", sub: "W3C · intent, examples, benefits")
            reading(link: x.quickRefURL, title: "How to meet \(x.num)", sub: "W3C quick reference · techniques & failures")
        }
    }

    private func neighbour(_ c: Criterion, forward: Bool) -> some View {
        Button { store.replaceCriterion(c.num) } label: {
            VStack(alignment: forward ? .trailing : .leading, spacing: 2) {
                Text(forward ? "\(c.num) →" : "← \(c.num)").face(.mono, 13).foregroundStyle(T.muted)
                Text(c.title).face(.sans, 14, lineHeight: 1.3).foregroundStyle(T.ink)
                    .multilineTextAlignment(forward ? .trailing : .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: forward ? .trailing : .leading)
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(T.line, lineWidth: 1))
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel((forward ? "Next: " : "Previous: ") + "\(c.num) \(c.title)")
    }

    private func reading(link: URL, title: String, sub: String) -> some View {
        Link(destination: link) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title).face(.sansBold, 16).foregroundStyle(T.ink)
                    Text(sub).face(.sans, 14).foregroundStyle(T.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "arrow.up.right").foregroundStyle(T.ink).accessibilityHidden(true)
            }
            .padding(.horizontal, 18)
            .frame(minHeight: 60)
            .background(RoundedRectangle(cornerRadius: 18).fill(T.card))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(T.line, lineWidth: 1))
        }
        .accessibilityHint("Opens in Safari")
    }
}

// MARK: - Depth

struct DepthPicker: View {
    @Environment(AppStore.self) var store

    var body: some View {
        let sel = store.depth, def = store.defaultDepth
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                ForEach(Depth.allCases, id: \.self) { d in
                    let on = sel == d
                    Button { store.depthOverride = d } label: {
                        VStack(spacing: 1) {
                            Text(d.label).face(.sansBold, 15)
                            Text(d.sub).face(.sans, 13).lineLimit(1).minimumScaleFactor(0.8)
                        }
                        .foregroundStyle(on ? T.onInk : T.body)
                        .padding(.horizontal, 4).padding(.vertical, 6)
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(RoundedRectangle(cornerRadius: 15).fill(on ? T.ink : Color.clear))
                        .contentShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .buttonStyle(PressStyle())
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(on ? [.isSelected] : [])
                }
            }
            .padding(5)
            .background(RoundedRectangle(cornerRadius: 20).fill(T.card))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(T.line, lineWidth: 1))
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Lesson depth")
            Text(sel == def
                 ? "Opened here for \(store.level) knowledge, \(store.role) scope. All three are open to you."
                 : "Your placement suggests “\(def.label)”. Read in any order.")
                .face(.sans, 14, lineHeight: 1.45).foregroundStyle(T.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct DepthContent: View {
    let x: Criterion
    let d: DeepLesson
    @Environment(AppStore.self) var store

    var body: some View {
        let tint = x.principle.tint.color
        VStack(alignment: .leading, spacing: 30) {
            switch store.depth {
            case .see:
                RuledSection(title: "WHO IT HELPS", spacing: 12) {
                    FlowLayout(spacing: 8, lineSpacing: 8) {
                        ForEach(d.who, id: \.self) { w in
                            Text(w).face(.sans, 15).foregroundStyle(T.ink)
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(Capsule().fill(T.chip))
                        }
                    }
                }
                RuledSection(title: "KEY TAKEAWAYS", spacing: 4) {
                    ForEach(Array(d.takeaways.enumerated()), id: \.offset) { i, t in
                        HStack(alignment: .top, spacing: 16) {
                            Text(String(format: "%02d", i + 1)).face(.serif, 30).foregroundStyle(tint)
                                .frame(width: 34, alignment: .leading).accessibilityHidden(true)
                            Text(t).face(.sans, 16, lineHeight: 1.5).foregroundStyle(T.ink)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 12)
                    }
                }
            case .apply:
                RuledSection(title: "COMMON FAILURES") {
                    ForEach(d.failures, id: \.self) { GlyphItem(glyph: "✕", color: T.rust, text: $0) }
                }
                RuledSection(title: "HOW TO CHECK YOUR DESIGN") {
                    ForEach(d.check, id: \.self) { GlyphItem(glyph: "✓", color: T.green, text: $0) }
                }
                RuledSection(title: "ANNOTATE AT HANDOFF") {
                    ForEach(d.spec, id: \.self) { GlyphItem(glyph: "✎", color: T.ink, text: $0) }
                }
            case .lead:
                RuledSection(title: "IN A REVIEW, ASK") {
                    ForEach(d.review, id: \.self) { GlyphItem(glyph: "?", color: T.ink, text: $0) }
                }
                RuledSection(title: "THE TRADE-OFF") {
                    Para(text: d.tradeoff, size: 17, color: T.ink)
                }
                RuledSection(title: "IN YOUR DESIGN SYSTEM") {
                    Para(text: d.system, size: 17, color: T.ink)
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("MAKE THE CASE").kicker(tint)
                    Text(d.pitch).face(.serif, 26, lineHeight: 1.15).foregroundStyle(T.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(tint, lineWidth: 1))
            }
        }
    }
}

// MARK: - Quick check

struct QuickCheck: View {
    let num: String
    let quiz: Quiz
    let tint: Color
    @Environment(AppStore.self) var store

    var body: some View {
        let ans = store.quick[num]
        VStack(alignment: .leading, spacing: 12) {
            Text("QUICK CHECK").kicker(tint)
            Text(quiz.question).face(.serif, 26, lineHeight: 1.1).foregroundStyle(T.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            VStack(spacing: 8) {
                ForEach(Array(quiz.options.enumerated()), id: \.offset) { i, t in
                    AnswerRow(title: t, picked: ans == i, answered: ans != nil, right: i == quiz.answer,
                              markRight: "✓ Correct", markWrong: "✕ Not quite") {
                        store.answerQuick(num, i)
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Answers")
            if ans != nil {
                Para(text: quiz.why, size: 15)
            }
        }
        .card()
    }
}
