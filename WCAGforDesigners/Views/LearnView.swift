import SwiftUI

struct LearnView: View {
    @Environment(AppStore.self) var store
    @Environment(\.layout) var layout
    @Environment(\.uiScale) var scale

    var body: some View {
        PageSpread(spacing: 36) {
            paths
        } second: {
            atlas
        }
    }

    // MARK: Overview: paths

    @ViewBuilder private var paths: some View {
        VStack(alignment: .leading, spacing: 12) {
            Headline(text: "Paths")
            Para(text: "Eighty-six criteria is a lot. A path puts a handful in the order you will need them.")
            VStack(spacing: 12) {
                ForEach(Library.paths) { p in PathCard(p: p) }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Choose a path")
        }
    }

    // MARK: Working page: the Atlas

    @ViewBuilder private var atlas: some View {
        VStack(alignment: .leading, spacing: 12) {
            Headline(text: "The Atlas", size: 44)
                .padding(.top, layout.spread ? 0 : 10)
            Para(text: "WCAG 2.2 is a tree. Four principles hold thirteen guidelines, which hold the testable success criteria.")
            HStack(spacing: 0) {
                stat("4", "principles", first: true)
                stat("13", "guidelines")
                stat("86", "criteria")
            }
            .overlay(alignment: .top) { Rectangle().fill(T.line).frame(height: 1) }
            .overlay(alignment: .bottom) { Rectangle().fill(T.line).frame(height: 1) }
        }

        VStack(spacing: 14) {
            ForEach(Library.principles) { p in PrincipleCard(p: p) }
        }

        VStack(alignment: .leading, spacing: 14) {
            Text("Three levels").face(.serif, 30).foregroundStyle(T.ink).accessibilityAddTraits(.isHeader)
            VStack(spacing: 0) {
                levelRow(.a, "The baseline.", "Miss these and some people can't use your product at all.")
                levelRow(.aa, "The target.", "Most accessibility laws and policies point to Level AA. It includes everything in A.")
                levelRow(.aaa, "Enhanced.", "Not required across whole sites, but worth meeting wherever you can.")
            }
            .overlay(alignment: .top) { Rectangle().fill(T.line).frame(height: 1) }
        }

        VStack(alignment: .leading, spacing: 14) {
            Text("Where WCAG meets the law").face(.serif, 30).foregroundStyle(T.ink).accessibilityAddTraits(.isHeader)
            Para(text: "Rules differ by country and change often. This is a starting map, not legal advice.", size: 15, color: T.muted)
            VStack(spacing: 0) {
                ForEach(Library.laws, id: \.law) { w in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(w.region).kicker(size: 13, tracking: 0.06)
                        Text(w.law).face(.sansBold, 17).foregroundStyle(T.ink)
                        Text(w.note).face(.sans, 15, lineHeight: 1.45).foregroundStyle(T.body).fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 14)
                    .overlay(alignment: .bottom) { Rectangle().fill(T.line).frame(height: 1) }
                    .accessibilityElement(children: .combine)
                }
            }
            .overlay(alignment: .top) { Rectangle().fill(T.line).frame(height: 1) }
        }
    }

    private func stat(_ n: String, _ label: String, first: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(n).face(.serif, 40).foregroundStyle(T.ink)
            Text(label).face(.sans, 14).foregroundStyle(T.muted)
        }
        .padding(.vertical, 14)
        .padding(.leading, first ? 0 : 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .leading) { if !first { Rectangle().fill(T.line).frame(width: 1) } }
        .accessibilityElement(children: .combine)
    }

    private func levelRow(_ l: Level, _ head: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            LevelBadge(level: l, minWidth: 52, height: 30, size: 13)
            (Text(head).font(Fonts.font(.sansBold, 15, scale: scale)).foregroundStyle(T.ink) + Text(" " + text))
                .face(.sans, 15, lineHeight: 1.5)
                .foregroundStyle(T.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) { Rectangle().fill(T.line).frame(height: 1) }
        .accessibilityElement(children: .combine)
    }
}

struct PathCard: View {
    let p: LearningPath
    @Environment(AppStore.self) var store

    var body: some View {
        let done = p.list.filter { store.isLearned($0) }.count
        let cur = p.id == store.pathID, rec = p.id == store.recommendedPathID
        Button { store.choosePath(p.id) } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(p.name).face(.serif, 28, lineHeight: 1).foregroundStyle(T.ink)
                    Spacer()
                    Text("\(done)/\(p.list.count)").face(.mono, 13).foregroundStyle(T.muted)
                }
                Text(p.desc).face(.sans, 15, lineHeight: 1.4).foregroundStyle(T.body).multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 10) {
                    GeometryReader { g in
                        ZStack(alignment: .leading) {
                            Capsule().fill(T.line2)
                            Capsule().fill(T.ink).frame(width: g.size.width * CGFloat(done) / CGFloat(max(1, p.list.count)))
                        }
                    }
                    .frame(height: 4)
                    if cur || rec {
                        Text(cur ? "Your path" : "Suggested").face(.sansBold, 13).foregroundStyle(T.bg)
                            .padding(.horizontal, 10).padding(.vertical, 3)
                            .background(Capsule().fill(cur ? T.ink : T.accent))
                    }
                }
                .frame(minHeight: 24)
            }
            .padding(.horizontal, 18).padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 22).fill(T.card))
            .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(cur ? T.ink : T.line, lineWidth: 1))
        }
        .buttonStyle(PressStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(cur ? [.isSelected] : [])
        .accessibilityValue("\(done) of \(p.list.count) learned")
    }
}

struct PrincipleCard: View {
    let p: Principle
    @Environment(AppStore.self) var store

    var body: some View {
        let list = WCAG.criteria(in: p)
        let learned = list.filter { store.isLearned($0.num) }.count
        Button { store.open(.principle(p.n - 1)) } label: {
            VStack(alignment: .leading, spacing: 0) {
                ParticleView(kind: p.particleKind, seed: 11 + (p.n - 1) * 17, options: ParticleOptions(tint: p.tint))
                    .frame(height: 150)
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("PRINCIPLE \(p.n)").face(.mono, 13, tracking: 0.08).foregroundStyle(p.tint.color)
                        Spacer()
                        Text("\(learned)/\(list.count) learned").face(.mono, 13).foregroundStyle(T.muted)
                    }
                    Text(p.name).face(.serif, 36, lineHeight: 1).foregroundStyle(T.ink)
                    Text(p.question).face(.sans, 15).foregroundStyle(T.body)
                }
                .padding(.horizontal, 20).padding(.top, 4).padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(T.card)
            .clipShape(RoundedRectangle(cornerRadius: 26))
            .overlay(RoundedRectangle(cornerRadius: 26).strokeBorder(T.line, lineWidth: 1))
        }
        .buttonStyle(PressStyle())
        .accessibilityElement(children: .combine)
    }
}

struct PrincipleView: View {
    let index: Int
    @Environment(AppStore.self) var store
    @Environment(\.layout) var layout
    @State var filter = "All"

    var body: some View {
        let p = Library.principles[index]
        let all = WCAG.criteria(in: p)
        PageSpread(resetID: index, spacing: 22) {
            ParticleView(kind: p.particleKind, seed: 101 + index * 13, options: ParticleOptions(tint: p.tint))
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 28))
            VStack(alignment: .leading, spacing: 12) {
                Text("PRINCIPLE \(p.n) · \(all.count) CRITERIA").face(.mono, 13, tracking: 0.08).foregroundStyle(p.tint.color)
                Headline(text: p.name)
                Para(text: p.desc)
            }
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(["All", "A", "AA", "AAA", "Designer-led"], id: \.self) { f in
                        Chip(label: f, on: filter == f, height: 40) { filter = f }
                    }
                }
                .padding(.vertical, 2)
            }
            .scrollIndicators(.hidden)
            .accessibilityLabel("Filter by level")
        } second: {
            let groups = guidelineGroups(p)
            if groups.isEmpty {
                Para(text: "No criteria at this level in this principle.", color: T.muted)
            }
            ForEach(groups) { group in
                let g = group.guideline, rows = group.rows
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("GUIDELINE \(g.num)").face(.mono, 13).foregroundStyle(T.muted)
                        Text(g.name).face(.serif, 28, lineHeight: 1.05).foregroundStyle(T.ink).accessibilityAddTraits(.isHeader)
                        Text(g.summary).face(.sans, 15, lineHeight: 1.45).foregroundStyle(T.muted).fixedSize(horizontal: false, vertical: true)
                    }
                    VStack(spacing: 0) {
                        ForEach(rows) { c in CriterionRow(c: c) }
                    }
                    .overlay(alignment: .top) { Rectangle().fill(T.line).frame(height: 1) }
                }
                .padding(.bottom, 14)
            }
        }
    }

    struct GuidelineGroup: Identifiable {
        let guideline: Guideline
        let rows: [Criterion]
        var id: String { guideline.num }
    }

    private func guidelineGroups(_ p: Principle) -> [GuidelineGroup] {
        let all = WCAG.criteria(in: p)
        var out: [GuidelineGroup] = []
        for g in WCAG.guidelines(in: p) {
            let rows = all.filter { $0.guidelineNum == g.num && matches($0) }
            if !rows.isEmpty { out.append(GuidelineGroup(guideline: g, rows: rows)) }
        }
        return out
    }

    private func matches(_ c: Criterion) -> Bool {
        switch filter {
        case "All": return true
        case "Designer-led": return c.designerLed
        default: return c.level.rawValue == filter
        }
    }
}

struct CriterionRow: View {
    let c: Criterion
    @Environment(AppStore.self) var store

    var body: some View {
        let on = store.isLearned(c.num)
        let tint = c.principle.tint.color
        Button { store.openCriterion(c.num) } label: {
            HStack(spacing: 12) {
                Text(c.num).face(.mono, 14).foregroundStyle(tint).frame(width: 48, alignment: .leading)
                Text(c.title).face(.sans, 16, lineHeight: 1.3).foregroundStyle(T.ink).multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if on { Text("●").face(.sans, 14).foregroundStyle(tint).accessibilityLabel("learned") }
                LevelBadge(level: c.level)
            }
            .padding(.horizontal, 8).padding(.vertical, 10)
            .frame(minHeight: 60)
            .overlay(alignment: .bottom) { Rectangle().fill(T.line).frame(height: 1) }
        }
        .buttonStyle(PressStyle())
        .accessibilityElement(children: .combine)
    }
}
