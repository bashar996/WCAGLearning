import SwiftUI

/// Placement: scope first, then six questions. Places you on the knowledge × scope matrix.
struct OnboardingView: View {
    @Environment(AppStore.self) var store
    @Environment(\.layout) var layout

    var body: some View {
        Group {
            switch store.placementStep {
            case .welcome: welcome
            case .role: role
            case .quiz: quiz
            case .result: result
            }
        }
        .animation(.easeInOut(duration: 0.25), value: store.placementStep)
    }

    // MARK: Welcome

    private var welcome: some View {
        PageSpread(resetID: "welcome", spacing: 24) {
            if !layout.spread { hero.frame(height: 170) }
            VStack(alignment: .leading, spacing: 16) {
                Text("PLACEMENT · 2 MIN").kicker()
                WelcomeTitle()
                Para(text: "A senior designer can be new to accessibility. A junior can know WCAG cold. Two quick steps place you on both, so lessons and practice fit.", size: 17)
                Button("Find my starting point") { store.beginPlacement() }
                    .buttonStyle(PillButtonStyle(fill: T.accent, onFill: T.bg, height: 56))
                Button("Skip for now") { store.skipPlacement() }
                    .buttonStyle(PillButtonStyle(border: T.mute2, height: 48, size: 15))
            }
            .padding(.top, layout.spread ? 40 : 0)
        } second: {
            if layout.spread { hero.frame(height: 400).padding(.top, 40) }
        }
    }

    private var hero: some View {
        ParticleView(kind: .understandable, seed: 77, options: ParticleOptions(tint: .accent))
            .clipShape(RoundedRectangle(cornerRadius: 28))
    }

    // MARK: Step 1

    private var role: some View {
        PageSpread(resetID: "role", spacing: 18) {
            VStack(alignment: .leading, spacing: 18) {
                Text("STEP 1 OF 2 · YOUR SCOPE").kicker()
                Headline(text: "What does your week look like?", size: 44)
                Para(text: "Choose by the work you do, not your job title.")
            }
        } second: {
            VStack(spacing: 10) {
                ForEach(Library.roles) { r in
                    Button { store.pickRole(r.id) } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(r.id).face(.serif, 28, lineHeight: 1).foregroundStyle(T.ink)
                            Text(r.desc).face(.sans, 15, lineHeight: 1.4).foregroundStyle(T.body)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 18).padding(.vertical, 16)
                        .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 20).fill(T.card))
                        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(T.line2, lineWidth: 1))
                    }
                    .buttonStyle(PressStyle())
                    .accessibilityElement(children: .combine)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Your scope")
        }
    }

    // MARK: Step 2

    private var quiz: some View {
        let i = min(store.diagIndex, Library.diagnostic.count - 1)
        let q = Library.diagnostic[i]
        return PageSpread(resetID: "quiz\(i)", spacing: 20) {
            VStack(alignment: .leading, spacing: 20) {
                Segments(colors: Library.diagnostic.indices.map { k -> Color in k < i ? T.ink : (k == i ? T.accent : T.line2) })
                Text("STEP 2 OF 2 · QUESTION \(i + 1) OF \(Library.diagnostic.count)").kicker()
                Headline(text: q.question, size: 32)
            }
        } second: {
            VStack(alignment: .leading, spacing: 14) {
                VStack(spacing: 8) {
                    ForEach(Array((q.options + ["I’m not sure"]).enumerated()), id: \.offset) { k, t in
                        Button { store.answerDiag(k) } label: {
                            Text(t).face(.sans, 16, lineHeight: 1.35).foregroundStyle(T.ink)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 16).padding(.vertical, 12)
                                .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
                                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(T.line2, lineWidth: 1))
                                .contentShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PressStyle())
                    }
                }
                Para(text: "No score is shown. “I’m not sure” is a useful answer.", size: 14, color: T.muted)
            }
        }
    }

    // MARK: Result

    private var result: some View {
        let recID = store.recommendedPathID
        let plan: [(String, String)] = [
            ("Lessons open on", store.defaultDepth.label),
            ("Your path", WCAG.path(recID).name),
            ("Your practice", store.roleTask.name),
        ]
        return PageSpread(resetID: "result", spacing: 22) {
            VStack(alignment: .leading, spacing: 22) {
                Text("YOUR STARTING POINT").kicker()
                Headline(text: "\(store.level) knowledge, \(store.role) scope.", size: 44)
                Para(text: Library.levelBlurbs[store.level] ?? "")
                MatrixView(level: store.level, role: store.role)
            }
        } second: {
            VStack(alignment: .leading, spacing: 22) {
                VStack(spacing: 0) {
                    ForEach(plan.indices, id: \.self) { i in
                        let k = plan[i].0, v = plan[i].1
                        HStack(alignment: .firstTextBaseline, spacing: 14) {
                            Text(k).face(.sans, 15).foregroundStyle(T.muted)
                            Spacer()
                            Text(v).face(.sansBold, 17).foregroundStyle(T.ink).multilineTextAlignment(.trailing)
                        }
                        .padding(.vertical, 14)
                        .overlay(alignment: .bottom) { Rectangle().fill(T.line).frame(height: 1) }
                        .accessibilityElement(children: .combine)
                    }
                }
                .overlay(alignment: .top) { Rectangle().fill(T.line).frame(height: 1) }
                Para(text: "Nothing is locked. Every depth and path stays open, and you can change this in You.", size: 14, color: T.muted)
                Button("Open the app") { store.finishPlacement() }
                    .buttonStyle(PillButtonStyle(fill: T.accent, onFill: T.bg, height: 56))
            }
        }
    }
}

private struct WelcomeTitle: View {
    @Environment(\.uiScale) var scale
    var body: some View {
        (Text("Start where you ")
            + Text("actually").font(Fonts.font(.serifItalic, 50, scale: scale)).foregroundStyle(T.accent)
            + Text(" are."))
            .font(Fonts.font(.serif, 50, scale: scale))
            .foregroundStyle(T.ink)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }
}
