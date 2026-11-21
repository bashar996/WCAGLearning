import SwiftUI
import Observation

enum AppTab: String, CaseIterable, Codable, Hashable {
    case today, learn, practice, you

    var label: String {
        switch self { case .today: return "Today"; case .learn: return "Learn"; case .practice: return "Practice"; case .you: return "You" }
    }
    var symbol: String {
        switch self { case .today: return "sun.max"; case .learn: return "book"; case .practice: return "target"; case .you: return "person" }
    }
    var selectedSymbol: String {
        switch self { case .today: return "sun.max.fill"; case .learn: return "book.fill"; case .practice: return "target"; case .you: return "person.fill" }
    }
}

enum Route: Hashable {
    case principle(Int)
    case criterion(String)
}

enum PlacementStep { case welcome, role, quiz, result }

enum PracticeMode: String, Codable { case review, name, role }

struct ReviewState: Codable, Equatable {
    var stage: Int
    var due: Date
}

struct PracticeProgress: Codable, Equatable {
    var index: Int = 0
    var answers: [Int] = []
}

struct Account: Codable, Equatable {
    var name: String
    var email: String
    var via: String
    var links: [String: Bool]

    var initials: String {
        let parts = name.trimmingCharacters(in: .whitespaces).split(whereSeparator: \.isWhitespace)
        let s = parts.prefix(2).compactMap { $0.first.map(String.init) }.joined()
        return s.isEmpty ? "?" : s.uppercased()
    }
}

/// Everything that survives a relaunch.
private struct Saved: Codable {
    var onboarded = false
    var role = "Mid"
    var level = "Working"
    var path = "first10"
    var learned: [String: Date] = [:]
    var reviews: [String: ReviewState] = [:]
    var quick: [String: Int] = [:]
    var practiceMode: PracticeMode = .name
    var practice: [String: PracticeProgress] = [:]
    var reviewList: [String] = []
    var textScale: Double = 1
    var still = false
    var noParticles = false
    var mirror = false
    var theme: ThemeChoice = .auto
    var account: Account?
}

@Observable
final class AppStore {
    // MARK: Persisted
    var onboarded: Bool
    var role: String
    var level: String
    var pathID: String
    var learned: [String: Date]
    var reviews: [String: ReviewState]
    var quick: [String: Int]
    var practiceMode: PracticeMode
    var practice: [String: PracticeProgress]
    var reviewList: [String]
    var textScale: Double
    var still: Bool
    var noParticles: Bool
    var mirror: Bool
    var theme: ThemeChoice
    var account: Account?

    // MARK: Session
    var tab: AppTab = .today
    var stacks: [AppTab: [Route]] = [:]
    var showPlacement: Bool
    var placementStep: PlacementStep = .welcome
    var diagIndex = 0
    var diagAnswers: [Int] = []
    var depthOverride: Depth?
    var toast: String?
    var now = Date()

    // Demo state, kept per session like the prototype.
    var contrastGray = 170
    var cvd = "none"
    var shapes = false
    var targetSize: Double = 24
    var demoReduced = false

    private static let key = "wcagfd-state-v1"
    @ObservationIgnored private var toastTask: Task<Void, Never>?

    init() {
        var s = Saved()
        if let data = UserDefaults.standard.data(forKey: Self.key),
           let decoded = try? JSONDecoder().decode(Saved.self, from: data) {
            s = decoded
        }
        onboarded = s.onboarded
        role = s.role
        level = s.level
        pathID = s.path
        learned = s.learned
        reviews = s.reviews
        quick = s.quick
        practiceMode = s.practiceMode
        practice = s.practice
        reviewList = s.reviewList
        textScale = s.textScale
        still = s.still
        noParticles = s.noParticles
        mirror = s.mirror
        theme = s.theme
        account = s.account
        showPlacement = !s.onboarded
    }

    func save() {
        let s = Saved(onboarded: onboarded, role: role, level: level, path: pathID, learned: learned, reviews: reviews,
                      quick: quick, practiceMode: practiceMode, practice: practice, reviewList: reviewList,
                      textScale: textScale, still: still, noParticles: noParticles, mirror: mirror, theme: theme,
                      account: account)
        if let data = try? JSONEncoder().encode(s) { UserDefaults.standard.set(data, forKey: Self.key) }
    }

    // MARK: Derived

    var path: LearningPath { WCAG.path(pathID) }
    var learnedCount: Int { learned.count }
    func isLearned(_ num: String) -> Bool { learned[num] != nil }

    /// Learned criteria whose next review date has passed, in WCAG order.
    var due: [String] {
        WCAG.order.filter { n in
            guard learned[n] != nil, let r = reviews[n] else { return false }
            return r.due <= now
        }
    }

    var defaultDepth: Depth { WCAG.defaultDepth(level: level, role: role) }
    var depth: Depth { depthOverride ?? defaultDepth }
    var recommendedPathID: String { WCAG.recommendedPath(level: level, role: role) }
    var roleTask: RoleTask { Library.roleTasks[role] ?? Library.roleTasks["Mid"]! }

    /// Today's lesson: the first unlearned criterion on your path that has a full lesson, else the first unlearned one.
    var featured: Criterion {
        let list = path.list
        let n = list.first { !isLearned($0) && Library.lessons[$0] != nil } ?? list.first { !isLearned($0) } ?? list[0]
        return WCAG.criterion(n)
    }

    // MARK: Navigation

    var currentStack: [Route] { stacks[tab] ?? [] }

    func select(_ t: AppTab) {
        if tab == t { stacks[t] = [] } // tapping the current tab returns to its top
        tab = t
    }

    func open(_ r: Route) { stacks[tab, default: []].append(r) }

    func openCriterion(_ num: String) { open(.criterion(num)) }

    /// Previous / next inside a lesson replaces the page rather than stacking up history.
    func replaceCriterion(_ num: String) {
        var s = stacks[tab] ?? []
        if case .criterion? = s.last { s.removeLast() }
        s.append(.criterion(num))
        stacks[tab] = s
    }

    func back() { _ = stacks[tab]?.popLast() }

    func stackBinding(_ t: AppTab) -> Binding<[Route]> {
        Binding(get: { self.stacks[t] ?? [] }, set: { self.stacks[t] = $0 })
    }

    // MARK: Toast

    func say(_ msg: String) {
        toastTask?.cancel()
        withAnimation(.easeOut(duration: 0.2)) { toast = msg }
        toastTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 2_400_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: 0.2)) { self?.toast = nil }
        }
    }

    // MARK: Learning

    func setLearned(_ num: String, _ on: Bool) {
        if on {
            guard learned[num] == nil else { return }
            learned[num] = Date()
            // First review a day after learning, then 3, 7, 21 and 60 days.
            reviews[num] = ReviewState(stage: 0, due: Self.days(Library.reviewIntervals[0]))
        } else {
            learned[num] = nil
            reviews[num] = nil
        }
        save()
    }

    func toggleLearned(_ num: String) {
        let was = isLearned(num)
        setLearned(num, !was)
        if !was { say("\(num) lit up on your map.") }
    }

    func answerQuick(_ num: String, _ i: Int) {
        guard quick[num] == nil, let lesson = Library.lessons[num] else { return }
        quick[num] = i
        if i == lesson.quiz.answer {
            setLearned(num, true)
            say("Correct — \(num) is now lit on your map.")
        }
        save()
    }

    static func days(_ n: Int) -> Date { Date().addingTimeInterval(Double(n) * 86_400) }

    // MARK: Placement

    func beginPlacement() { placementStep = .role }

    func skipPlacement() {
        onboarded = true
        showPlacement = false
        placementStep = .welcome
        save()
    }

    func pickRole(_ r: String) {
        role = r
        diagIndex = 0
        diagAnswers = []
        placementStep = .quiz
    }

    func answerDiag(_ i: Int) {
        diagAnswers.append(i)
        if diagAnswers.count < Library.diagnostic.count {
            diagIndex += 1
            return
        }
        let score = zip(diagAnswers, Library.diagnostic).filter { $0.0 == $0.1.answer }.count
        level = score <= 2 ? "New" : score <= 4 ? "Working" : "Fluent"
        pathID = WCAG.recommendedPath(level: level, role: role)
        depthOverride = nil
        placementStep = .result
        save()
    }

    func finishPlacement() {
        onboarded = true
        showPlacement = false
        placementStep = .welcome
        tab = .today
        save()
    }

    func retakePlacement() {
        placementStep = .welcome
        showPlacement = true
    }

    // MARK: Paths and scope

    func choosePath(_ id: String) {
        pathID = id
        stacks[.today] = []
        tab = .today
        say("\(WCAG.path(id).name) is now your path.")
        save()
    }

    func setRole(_ r: String) {
        role = r
        depthOverride = nil
        save()
    }

    // MARK: Practice

    struct PracticeItem {
        let text: String
        let options: [(num: String, title: String, tint: Tint?)]
        let answer: Int
        let why: String
        let criterion: String
    }

    var practiceKey: String { practiceMode == .role ? role : practiceMode.rawValue }

    var practiceItems: [PracticeItem] {
        func opt(_ n: String) -> (num: String, title: String, tint: Tint?) {
            let c = WCAG.criterion(n)
            return (n, c.title, c.principle.tint)
        }
        switch practiceMode {
        case .name:
            return Library.scenarios.map {
                PracticeItem(text: $0.text, options: $0.options.map(opt), answer: $0.answer, why: $0.why, criterion: $0.options[$0.answer])
            }
        case .review:
            return reviewList.map { n in
                // Same distractor recipe as the prototype: two siblings from the same principle.
                let x = WCAG.criterion(n)
                let pool = WCAG.criteria(in: x.principle).map(\.num).filter { $0 != n }
                let i1 = x.seed % pool.count
                var i2 = (i1 + 5) % pool.count
                if i2 == i1 { i2 = (i1 + 1) % pool.count }
                var o = [pool[i1], pool[i2]]
                let pos = x.seed % 3
                o.insert(n, at: pos)
                return PracticeItem(text: x.summary, options: o.map(opt), answer: pos, why: "", criterion: n)
            }
        case .role:
            return roleTask.questions.map { q in
                PracticeItem(text: q.text,
                             options: q.options.enumerated().map { (num: ["A", "B", "C"][$0.offset], title: $0.element, tint: Tint?.none) },
                             answer: q.answer, why: q.why, criterion: q.criterion)
            }
        }
    }

    var progress: PracticeProgress { practice[practiceKey] ?? PracticeProgress() }

    func setPracticeMode(_ m: PracticeMode) {
        if m == .review {
            let r = practice[PracticeMode.review.rawValue]
            let midway = r.map { !$0.answers.isEmpty && $0.index < reviewList.count } ?? false
            if !midway {
                reviewList = due
                practice[PracticeMode.review.rawValue] = PracticeProgress()
            }
        }
        practiceMode = m
        save()
    }

    func startReview() {
        setPracticeMode(.review)
        stacks[.practice] = []
        tab = .practice
    }

    func answerPractice(_ i: Int) {
        let items = practiceItems
        var p = progress
        guard p.index < items.count, p.answers.count == p.index else { return }
        p.answers.append(i)
        practice[practiceKey] = p
        let item = items[p.index]
        if practiceMode == .review {
            let n = item.criterion
            let stage = reviews[n]?.stage ?? 0
            if i == item.answer {
                let next = min(stage + 1, Library.reviewIntervals.count - 1)
                reviews[n] = ReviewState(stage: stage + 1, due: Self.days(Library.reviewIntervals[next]))
            } else {
                reviews[n] = ReviewState(stage: 0, due: Self.days(1))
            }
        }
        save()
    }

    func nextPractice() {
        var p = progress
        p.index += 1
        practice[practiceKey] = p
        save()
    }

    func restartPractice() {
        if practiceMode == .review {
            now = Date()
            if due.isEmpty {
                tab = .today
            } else {
                reviewList = due
                practice[PracticeMode.review.rawValue] = PracticeProgress()
            }
        } else {
            practice[practiceKey] = PracticeProgress()
        }
        save()
    }

    /// Spaced-review interval shown after a correct recall.
    func nextReviewDays(for n: String) -> Int {
        let stage = reviews[n]?.stage ?? 1
        return Library.reviewIntervals[min(max(stage, 1), Library.reviewIntervals.count - 1)]
    }

    // MARK: Settings

    func setTheme(_ t: ThemeChoice) { theme = t; t.apply(); save() }
    func setTextScale(_ v: Double) { textScale = v; save() }
    func toggleStill() { still.toggle(); save() }
    func toggleNoParticles() { noParticles.toggle(); save() }
    func toggleMirror() { mirror.toggle(); save() }

    // MARK: Account (local only for now)

    func signIn(name: String, email: String, via: String) {
        account = Account(name: name, email: email, via: via, links: via == "Email" ? [:] : [via: true])
        save()
    }

    func updateAccount(_ change: (inout Account) -> Void) {
        guard var a = account else { return }
        change(&a)
        account = a
        save()
    }

    func signOut() {
        account = nil
        save()
    }

    func refreshClock() { now = Date() }
}
