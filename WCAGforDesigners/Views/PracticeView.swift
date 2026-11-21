import SwiftUI

struct PracticeView: View {
    @Environment(AppStore.self) var store
    @Environment(\.layout) var layout

    var body: some View {
        let items = store.practiceItems
        let p = store.progress
        let total = items.count
        let active = p.index < total
        let item: AppStore.PracticeItem? = active ? items[p.index] : nil
        let picked: Int? = p.answers.count > p.index ? p.answers[p.index] : nil
        let mode = store.practiceMode

        PageSpread(resetID: "\(store.practiceKey)-\(p.index)-\(active)", spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Headline(text: "Practice")
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        Chip(label: "Review · \(store.due.count)", on: mode == .review) { store.setPracticeMode(.review) }
                        Chip(label: "Name it", on: mode == .name) { store.setPracticeMode(.name) }
                        Chip(label: store.roleTask.name, on: mode == .role) { store.setPracticeMode(.role) }
                    }
                    .padding(.vertical, 2)
                }
                .scrollIndicators(.hidden)
                .accessibilityLabel("Practice mode")
                Para(text: description(mode))
                if layout.spread, let item {
                    scenarioCard(item, index: p.index, total: total).padding(.top, 14)
                }
            }
        } second: {
            Segments(colors: items.indices.map { i -> Color in
                i < p.answers.count ? (p.answers[i] == items[i].answer ? T.green : T.rust) : i == p.index ? T.ink : T.line2
            })
            if let item {
                if !layout.spread {
                    scenarioCard(item, index: p.index, total: total)
                }
                VStack(spacing: 8) {
                    ForEach(Array(item.options.enumerated()), id: \.offset) { i, o in
                        AnswerRow(title: o.title, picked: picked == i, answered: picked != nil, right: i == item.answer,
                                  minHeight: 62) {
                            Text(o.num).face(.mono, 14).foregroundStyle(o.tint?.color ?? T.muted).frame(width: 48, alignment: .leading)
                        } action: {
                            store.answerPractice(i)
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Answers")
                .sensoryFeedback(trigger: picked) { _, new in
                    guard let new else { return nil }
                    return new == item.answer ? .success : .error
                }
                if let picked {
                    feedback(item, picked: picked, index: p.index, total: total)
                }
            } else {
                results(items, progress: p)
            }
        }
    }

    private func description(_ m: PracticeMode) -> String {
        switch m {
        case .review: return "Recall beats re-reading. Each line is something you have learned. Name it to keep its dot lit."
        case .role: return store.roleTask.desc
        case .name: return "Read the problem. Name the criterion it fails. That is how audits and reviews with developers go."
        }
    }

    private func scenarioCard(_ item: AppStore.PracticeItem, index: Int, total: Int) -> some View {
        let kind = store.practiceMode == .review ? "REVIEW" : store.practiceMode == .role ? "\(store.role.uppercased()) TASK" : "SCENARIO"
        return VStack(alignment: .leading, spacing: 14) {
            Text("\(kind) \(index + 1) OF \(total)").kicker(size: 13, tracking: 0.08)
            Text(item.text).face(.serif, 30, lineHeight: 1.1).foregroundStyle(T.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
        }
        .card(radius: 26, padding: 22)
    }

    @ViewBuilder
    private func feedback(_ item: AppStore.PracticeItem, picked: Int, index: Int, total: Int) -> some View {
        let right = picked == item.answer
        let mode = store.practiceMode
        let head = right ? "Right." : mode == .role ? "Not quite." : "It’s \(item.criterion)."
        let why = mode == .review
            ? (right ? "It stays lit. Next review in \(store.nextReviewDays(for: item.criterion)) days." : "It comes back tomorrow, until it sticks.")
            : item.why
        VStack(alignment: .leading, spacing: 12) {
            (Text(head).foregroundStyle(right ? T.green : T.rust).bold() + Text(" " + why).foregroundStyle(T.ink))
                .face(.sans, 16, lineHeight: 1.5)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 10) {
                Button("Read \(item.criterion)") { store.openCriterion(item.criterion) }
                    .buttonStyle(PillButtonStyle(size: 15))
                Button(index == total - 1 ? "See results" : "Next") { store.nextPractice() }
                    .buttonStyle(PillButtonStyle(fill: T.ink, size: 15))
            }
        }
    }

    @ViewBuilder
    private func results(_ items: [AppStore.PracticeItem], progress p: PracticeProgress) -> some View {
        let total = items.count
        let score = zip(p.answers, items).filter { $0.0 == $0.1.answer }.count
        let missed = missedCriteria(items, progress: p)
        let mode = store.practiceMode
        let summary = summaryText(mode, score: score, total: total)

        VStack(alignment: .leading, spacing: 18) {
            if total > 0 {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text("\(score)").face(.serif, 110).foregroundStyle(T.ink)
                    Text("/ \(total)").face(.serif, 40).foregroundStyle(T.muted)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Score \(score) of \(total)")
            }
            Para(text: summary, size: 17, color: T.ink)
            if !missed.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("WORTH A RE-READ").kicker().padding(.top, 14).padding(.bottom, 6)
                    ForEach(missed, id: \.self) { n in
                        let c = WCAG.criterion(n)
                        Button { store.openCriterion(n) } label: {
                            HStack(spacing: 12) {
                                Text(n).face(.mono, 14).foregroundStyle(c.principle.tint.color).frame(width: 48, alignment: .leading)
                                Text(c.title).face(.sans, 16).foregroundStyle(T.ink).frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "arrow.right").foregroundStyle(T.ink).flipsForRightToLeftLayoutDirection(true).accessibilityHidden(true)
                            }
                            .padding(.vertical, 8).frame(minHeight: 56)
                            .overlay(alignment: .bottom) { Rectangle().fill(T.line).frame(height: 1) }
                        }
                        .buttonStyle(PressStyle())
                    }
                }
                .overlay(alignment: .top) { Rectangle().fill(T.line).frame(height: 1) }
            }
            Button(mode == .review ? (store.due.isEmpty ? "Back to Today" : "Review what is still due") : "Try again") {
                store.restartPractice()
            }
            .buttonStyle(PillButtonStyle(fill: T.ink, height: 56))
        }
    }

    private func missedCriteria(_ items: [AppStore.PracticeItem], progress p: PracticeProgress) -> [String] {
        var seen = Set<String>()
        var out: [String] = []
        for (a, item) in zip(p.answers, items) where a != item.answer {
            if seen.insert(item.criterion).inserted { out.append(item.criterion) }
        }
        return out
    }

    private func summaryText(_ mode: PracticeMode, score: Int, total: Int) -> String {
        switch mode {
        case .review:
            if total == 0 { return "Nothing is due. A review appears a day after you learn something, then at 3, 7 and 21 days." }
            return score == total ? "All recalled. Those dots stay lit." : "The ones you missed come back tomorrow."
        case .role:
            return score == total ? "Clean run. That is the judgment this scope asks for." : "Each miss links to the criterion behind it."
        case .name:
            if score == total { return "Flawless. You can map problems to criteria like an auditor." }
            return Double(score) >= Double(total) * 0.6 ? "Solid. Re-read the ones you missed, then try again tomorrow." : "A good start. Each miss below links to its lesson."
        }
    }
}
