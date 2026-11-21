import Foundation

enum Level: String, Codable, CaseIterable {
    case a = "A", aa = "AA", aaa = "AAA"
}

enum DemoKind: String, Codable {
    case contrast, color, taps, motion
    case focus, resize, formErrors, readingOrder
}

struct Principle: Identifiable, Hashable {
    let n: Int
    let id: String
    let name: String
    let question: String
    let desc: String

    var tint: Tint {
        switch id {
        case "P": return .perceivable
        case "O": return .operable
        case "U": return .understandable
        default: return .robust
        }
    }
    var particleKind: ParticleKind {
        switch id {
        case "P": return .perceivable
        case "O": return .operable
        case "U": return .understandable
        default: return .robust
        }
    }
}

struct Guideline: Hashable {
    let num: String
    let name: String
    let summary: String
}

struct Criterion: Identifiable, Hashable {
    let num: String
    let title: String
    let level: Level
    let designerLed: Bool
    let summary: String

    var id: String { num }

    var principle: Principle { Library.principles[Int(String(num.prefix(1)))! - 1] }
    var guidelineNum: String { num.split(separator: ".").prefix(2).joined(separator: ".") }
    var guideline: Guideline { WCAG.guideline[guidelineNum]! }
    var slug: String {
        let lower = title.lowercased()
        var out = ""
        var lastDash = false
        for ch in lower {
            if ch.isASCII && (ch.isLetter || ch.isNumber) {
                out.append(ch); lastDash = false
            } else if !lastDash {
                out.append("-"); lastDash = true
            }
        }
        return out.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
    /// Same seed formula as the prototype so each poster matches its web twin.
    var seed: Int { (Int(num.replacingOccurrences(of: ".", with: "")) ?? 1) * 7 + 3 }
    var isNew: Bool { Library.newIn22.contains(num) }
    var lesson: DeepLesson? { Library.lessons[num] }
    var understandingURL: URL { URL(string: "https://www.w3.org/WAI/WCAG22/Understanding/\(slug).html")! }
    var quickRefURL: URL { URL(string: "https://www.w3.org/WAI/WCAG22/quickref/#\(slug)")! }
}

struct Quiz: Hashable {
    let question: String
    let options: [String]
    let answer: Int
    let why: String
}

struct DeepLesson: Hashable {
    let meta: String
    let demo: DemoKind?
    let who: [String]
    let takeaways: [String]
    let failures: [String]
    let check: [String]
    let quiz: Quiz
    let spec: [String]
    let review: [String]
    let tradeoff: String
    let system: String
    let pitch: String
}

struct LearningPath: Identifiable, Hashable {
    let id: String
    let name: String
    let desc: String
    let list: [String]
}

struct Scenario: Hashable {
    let text: String
    let options: [String]
    let answer: Int
    let why: String
}

struct Role: Identifiable, Hashable {
    let id: String
    let desc: String
}

struct DiagQuestion: Hashable {
    let question: String
    let options: [String]
    let answer: Int
}

struct RoleQuestion: Hashable {
    let text: String
    let options: [String]
    let answer: Int
    let criterion: String
    let why: String
}

struct RoleTask: Hashable {
    let name: String
    let desc: String
    let questions: [RoleQuestion]
}

struct Law: Hashable {
    let region: String
    let law: String
    let note: String
}

enum Depth: String, CaseIterable, Codable {
    case see, apply, lead
    var label: String {
        switch self { case .see: return "See it"; case .apply: return "Apply it"; case .lead: return "Lead it" }
    }
    var sub: String {
        switch self { case .see: return "what and why"; case .apply: return "spec and check"; case .lead: return "review, decide" }
    }
}

/// Lookups derived once from `Library`.
enum WCAG {
    static let order: [String] = Library.criteria.map(\.num)
    static let byNum: [String: Criterion] = Dictionary(uniqueKeysWithValues: Library.criteria.map { ($0.num, $0) })
    static let guideline: [String: Guideline] = Dictionary(uniqueKeysWithValues: Library.guidelines.map { ($0.num, $0) })
    static let total = Library.criteria.count

    static func criterion(_ num: String) -> Criterion { byNum[num] ?? Library.criteria[0] }
    static func criteria(in p: Principle) -> [Criterion] { Library.criteria.filter { $0.principle.id == p.id } }
    static func guidelines(in p: Principle) -> [Guideline] { Library.guidelines.filter { $0.num.hasPrefix("\(p.n).") } }

    static func neighbour(of num: String, offset: Int) -> Criterion {
        let i = order.firstIndex(of: num) ?? 0
        let n = order.count
        return criterion(order[((i + offset) % n + n) % n])
    }

    static func recommendedPath(level: String, role: String) -> String {
        if level == "New" { return "first10" }
        if role == "Lead" { return "systems" }
        if role == "Senior" { return "review" }
        if level == "Fluent" { return "systems" }
        return "forms"
    }

    static func defaultDepth(level: String, role: String) -> Depth {
        if level == "New" { return .see }
        if level == "Fluent" || role == "Senior" || role == "Lead" { return .lead }
        return .apply
    }

    static func path(_ id: String) -> LearningPath { Library.paths.first { $0.id == id } ?? Library.paths[0] }
}
