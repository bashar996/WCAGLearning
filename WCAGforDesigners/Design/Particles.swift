import SwiftUI

/// The animated artwork. Each WCAG principle has its own behaviour; the four lesson demos reuse the same engine.
enum ParticleKind: Hashable {
    case perceivable, operable, understandable, robust
    case contrast, color, taps, motion

    var isPoster: Bool {
        switch self { case .perceivable, .operable, .understandable, .robust: return true; default: return false }
    }
}

/// Inputs a demo changes while it runs.
struct ParticleOptions: Equatable {
    var tint: Tint = .accent
    var fg: Color = .gray          // contrast: text grey
    var shapes = false              // colour: add triangles
    var cvd = "none"                // colour: vision simulation
    var size: Double = 24           // taps: target size
    var reduced = false             // motion: reduce motion switch
}

/// Seeded generator identical to the prototype's mulberry32, so posters look the same as on the web.
struct Mulberry32 {
    private var a: UInt32
    init(seed: Int) { a = UInt32(truncatingIfNeeded: seed) }
    mutating func next() -> Double {
        a = a &+ 0x6D2B_79F5
        var t = (a ^ (a >> 15)) &* (1 | a)
        t = (t &+ ((t ^ (t >> 7)) &* (61 | t))) ^ t
        return Double(t ^ (t >> 14)) / 4_294_967_296
    }
}

private let SIGMA = 9.0

private func gauss(_ r: inout Mulberry32) -> Double {
    let u = r.next()
    return sqrt(-2 * log(u == 0 ? 1e-6 : u)) * cos(6.2832 * r.next())
}

private func smooth(_ a: Double, _ b: Double, _ x: Double) -> Double {
    let t = max(0, min(1, (x - a) / (b - a)))
    return t * t * (3 - 2 * t)
}

private func bez(_ p: [CGPoint], _ u: Double) -> CGPoint {
    let v = 1 - u
    let b0: Double = v * v * v, b1: Double = 3 * v * v * u, b2: Double = 3 * v * u * u, b3: Double = u * u * u
    let x0 = Double(p[0].x), x1 = Double(p[1].x), x2 = Double(p[2].x), x3 = Double(p[3].x)
    let y0 = Double(p[0].y), y1 = Double(p[1].y), y2 = Double(p[2].y), y3 = Double(p[3].y)
    let x: Double = b0 * x0 + b1 * x1 + b2 * x2 + b3 * x3
    let y: Double = b0 * y0 + b1 * y1 + b2 * y2 + b3 * y3
    return CGPoint(x: x, y: y)
}

private extension GraphicsContext {
    func dot(_ x: Double, _ y: Double, _ r: Double, _ c: Color) {
        fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(c))
    }
    func ring(_ x: Double, _ y: Double, _ r: Double, _ c: Color, width: Double) {
        stroke(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(c), lineWidth: width)
    }
}

/// Simulation state for one canvas. Rebuilt when the kind, seed or size changes.
final class ParticleSim {
    private var sig = ""
    private var rng = Mulberry32(seed: 1)

    // Per-kind state
    private var pts: [(x: Double, y: Double, z: Double)] = []
    private var ph = 0.0
    private var paths: [[CGPoint]] = []
    private var movers: [(pi: Int, u: Double, sp: Double, r: Double)] = []
    private var grid: [(gx: Double, gy: Double, cx: Double, cy: Double, ph: Double)] = []
    private var nodes: [(x: Double, y: Double, ph: Double, hl: Bool)] = []
    private var edges: [(Int, Int)] = []
    private var drift: [(x: Double, y: Double, r: Double, sp: Double, ph: Double)] = []
    private var projects: [(x: Double, y: Double, risk: Bool, ph: Double)] = []
    private var taps: [(dx: Double, dy: Double, t0: Double)] = []
    private var lastTap = 0.0
    private var layers: [(x: Double, y: Double, l: Int, ph: Double)] = []

    func setup(_ kind: ParticleKind, seed: Int, w: Double, h: Double) {
        let s = "\(kind)|\(seed)|\(Int(w))|\(Int(h))"
        guard s != sig else { return }
        sig = s
        var R = Mulberry32(seed: seed == 0 ? 1 : seed)
        switch kind {
        case .perceivable:
            let step = 12 + floor(R.next() * 5)
            pts = []
            var y = step / 2
            while y < h {
                var x = step / 2
                while x < w { pts.append((x + (R.next() - 0.5) * 2, y + (R.next() - 0.5) * 2, R.next())); x += step }
                y += step
            }
            ph = R.next() * 10
        case .operable:
            let n = 3 + Int(floor(R.next() * 3))
            var built: [[CGPoint]] = []
            for _ in 0..<n {
                let y0: Double = h * R.next()
                let x1: Double = w * (0.15 + 0.3 * R.next()), y1: Double = h * R.next()
                let x2: Double = w * (0.45 + 0.3 * R.next()), y2: Double = h * R.next()
                let x3: Double = w * (0.7 + 0.2 * R.next()), y3: Double = h * (0.18 + 0.64 * R.next())
                built.append([CGPoint(x: -10.0, y: y0), CGPoint(x: x1, y: y1), CGPoint(x: x2, y: y2), CGPoint(x: x3, y: y3)])
            }
            paths = built
            movers = (0..<80).map { i in (i % n, R.next(), 0.035 + R.next() * 0.05, 0.8 + R.next() * 1.4) }
        case .understandable:
            let step = 20 + floor(R.next() * 6)
            grid = []
            var y = step
            while y < h - step / 2 {
                var x = step
                while x < w - step / 2 { grid.append((x, y, R.next() * w, R.next() * h, R.next() * 6.28)); x += step }
                y += step
            }
            ph = R.next() * 6
        case .robust:
            let step = 30 + floor(R.next() * 8)
            nodes = []
            var row = 0
            var y = step / 2
            while y < h + step {
                var x = row % 2 == 1 ? step / 2 : 0
                while x < w + step { nodes.append((x, y, R.next() * 6.28, R.next() < 0.1)); x += step }
                y += step * 0.866
                row += 1
            }
            edges = []
            for i in 0..<nodes.count {
                for j in (i + 1)..<max(i + 1, nodes.count) where hypot(nodes[i].x - nodes[j].x, nodes[i].y - nodes[j].y) < step * 1.05 {
                    edges.append((i, j))
                }
            }
        case .contrast:
            drift = (0..<110).map { _ in (R.next() * w, R.next() * h, 0.8 + R.next() * 2.2, 4 + R.next() * 10, R.next() * 6) }
        case .color:
            projects = (0..<46).map { i in (20 + R.next() * (w - 40), 20 + R.next() * (h - 40), i % 4 == 0, R.next() * 6) }
        case .taps:
            taps = (0..<64).map { _ in (gauss(&R) * SIGMA, gauss(&R) * SIGMA, -1e9) }
            lastTap = 0
        case .motion:
            layers = (0..<120).map { _ in (R.next() * w, R.next() * h, 1 + Int(floor(R.next() * 3)), R.next() * 6) }
        }
        rng = R
    }

    func draw(_ c: GraphicsContext, kind: ParticleKind, w: Double, h: Double, t: Double, still: Bool,
              o: ParticleOptions, dark: Bool) {
        let color = o.tint.resolved(dark: dark)
        let off = Tint.ink.resolved(dark: dark)
        switch kind {
        case .perceivable:
            let fx = w * (0.5 + 0.34 * sin(t * 0.21 + ph)), fy = h * (0.5 + 0.3 * cos(t * 0.16 + ph * 1.7)), m = max(w, h) * 0.5
            for p in pts {
                let a = max(0, 1 - hypot(p.x - fx, p.y - fy) / m), k = a * a
                c.dot(p.x, p.y, 1 + 3.2 * k + p.z * 0.5, k > 0.42 ? color.opacity(0.4 + 0.6 * k) : off.opacity(0.18 + 0.5 * k))
            }
        case .operable:
            for p in paths {
                var path = Path()
                path.move(to: p[0]); path.addCurve(to: p[3], control1: p[1], control2: p[2])
                c.stroke(path, with: .color(off.opacity(0.3)), lineWidth: 1.25)
            }
            for (i, p) in paths.enumerated() {
                let ex = Double(p[3].x), ey = Double(p[3].y)
                c.ring(ex, ey, 9 + 2 * sin(t * 2 + Double(i)), color.opacity(0.85), width: 1.5)
                c.dot(ex, ey, 2.5, color)
            }
            for q in movers {
                let p = paths[q.pi]
                let u0 = (q.u + t * q.sp).truncatingRemainder(dividingBy: 1)
                for k in stride(from: 4, through: 0, by: -1) {
                    let u = u0 - Double(k) * 0.012
                    if u < 0 { continue }
                    let pt = bez(p, u)
                    c.dot(Double(pt.x), Double(pt.y), k == 0 ? q.r + 1.4 : q.r, k == 0 ? color.opacity(0.95) : off.opacity(0.5 - Double(k) * 0.08))
                }
            }
        case .understandable:
            let e = smooth(0.2, 0.8, 0.5 - 0.5 * cos(t * 0.42 + ph))
            for q in grid {
                let cx = q.cx + sin(t * 0.6 + q.ph) * 16, cy = q.cy + cos(t * 0.5 + q.ph) * 16
                let x = cx + (q.gx - cx) * e, y = cy + (q.gy - cy) * e, r = 1.9 + 2 * e
                let col = e > 0.5 ? color.opacity(0.3 + 0.7 * e) : off.opacity(0.42 + 0.3 * (1 - e))
                if e > 0.6 { c.fill(Path(CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(col)) }
                else { c.dot(x, y, r, col) }
            }
        case .robust:
            let P: [CGPoint] = nodes.map { n -> CGPoint in
                let x: Double = n.x + sin(t * 0.8 + n.ph) * 3
                let y: Double = n.y + cos(t * 0.7 + n.ph) * 3
                return CGPoint(x: x, y: y)
            }
            var hot = Path(), cold = Path()
            for (i, j) in edges {
                if nodes[i].hl || nodes[j].hl { hot.move(to: P[i]); hot.addLine(to: P[j]) }
                else { cold.move(to: P[i]); cold.addLine(to: P[j]) }
            }
            c.stroke(cold, with: .color(off.opacity(0.3)), lineWidth: 1)
            c.stroke(hot, with: .color(color.opacity(0.6)), lineWidth: 1)
            for (i, n) in nodes.enumerated() {
                let px = Double(P[i].x), py = Double(P[i].y)
                c.dot(px, py, n.hl ? 4.4 : 2.2, n.hl ? color : off.opacity(0.6))
                if n.hl { c.ring(px, py, 8 + 2 * sin(t * 1.5 + n.ph), color.opacity(0.3), width: 1) }
            }
        case .contrast:
            c.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)), with: .color(.white))
            for p in drift {
                let y = ((p.y - t * p.sp).truncatingRemainder(dividingBy: h) + h).truncatingRemainder(dividingBy: h)
                c.dot(p.x + sin(t * 0.5 + p.ph) * 6, y, p.r, o.fg)
            }
        case .color:
            let risk = simulate(0xE0533D, o.cvd), ok = simulate(0x3FA34D, o.cvd)
            for p in projects {
                let x = p.x + sin(t * 0.6 + p.ph) * 3, y = p.y + cos(t * 0.5 + p.ph) * 3
                if o.shapes && p.risk {
                    var tri = Path()
                    tri.move(to: CGPoint(x: x, y: y - 8)); tri.addLine(to: CGPoint(x: x + 8, y: y + 6)); tri.addLine(to: CGPoint(x: x - 8, y: y + 6)); tri.closeSubpath()
                    c.fill(tri, with: .color(risk))
                } else {
                    c.dot(x, y, 6.5, p.risk ? risk : ok)
                }
            }
        case .taps:
            let cx = w / 2, cy = h / 2, s = o.size
            if !still && t - lastTap > 0.11 {
                lastTap = t
                taps.append((gauss(&rng) * SIGMA, gauss(&rng) * SIGMA, t))
                if taps.count > 64 { taps.removeFirst() }
            }
            c.stroke(Path(ellipseIn: CGRect(x: cx - 12, y: cy - 12, width: 24, height: 24)), with: .color(off.opacity(0.5)),
                     style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
            let rect = Path(CGRect(x: cx - s / 2, y: cy - s / 2, width: s, height: s))
            c.fill(rect, with: .color(color.opacity(0.2)))
            c.stroke(rect, with: .color(color), lineWidth: 1.5)
            for p in taps {
                let a = still || p.t0 < 0 ? 0.7 : max(0.15, 1 - (t - p.t0) / 7)
                let hit = abs(p.dx) <= s / 2 && abs(p.dy) <= s / 2
                if hit { c.dot(cx + p.dx, cy + p.dy, 2.4, color.opacity(a)) }
                else { c.ring(cx + p.dx, cy + p.dy, 2.6, off.opacity(a), width: 1.2) }
            }
        case .motion:
            let m = o.reduced || still
            for p in layers {
                let l = Double(p.l), sp = l * l * 14
                let x = m ? p.x : (p.x + t * sp).truncatingRemainder(dividingBy: w + 20) - 10
                let y = m ? p.y : p.y + sin(t * 1.4 * l + p.ph) * 10 * l
                c.dot(x, y, l * 1.3, p.l == 3 ? color.opacity(0.95) : off.opacity(0.2 + 0.2 * l))
            }
        }
    }

    /// Colour-vision simulation, the same sRGB matrices as the prototype's SVG filters.
    private func simulate(_ rgb: UInt32, _ mode: String) -> Color {
        let r = Double((rgb >> 16) & 0xFF) / 255, g = Double((rgb >> 8) & 0xFF) / 255, b = Double(rgb & 0xFF) / 255
        let m: [Double]
        switch mode {
        case "protan": m = [0.567, 0.433, 0, 0.558, 0.442, 0, 0, 0.242, 0.758]
        case "deutan": m = [0.625, 0.375, 0, 0.7, 0.3, 0, 0, 0.3, 0.7]
        case "achro": m = [0.299, 0.587, 0.114, 0.299, 0.587, 0.114, 0.299, 0.587, 0.114]
        default: return Color(rgb: rgb)
        }
        return Color(.sRGB, red: m[0] * r + m[1] * g + m[2] * b,
                     green: m[3] * r + m[4] * g + m[5] * b,
                     blue: m[6] * r + m[7] * g + m[8] * b, opacity: 1)
    }
}

/// App start, so animation time starts near zero like `performance.now()`.
enum AppClock { static let start = Date() }

/// A particle canvas. Holds still when Reduce Motion is on (system or in-app) and goes flat with "Hide particles".
struct ParticleView: View {
    let kind: ParticleKind
    let seed: Int
    var options = ParticleOptions()

    @Environment(AppStore.self) var store
    @Environment(\.colorScheme) var scheme
    @Environment(\.accessibilityReduceMotion) var osReduce
    @State var sim = ParticleSim()

    var body: some View {
        let still = store.still || osReduce
        let dark = scheme == .dark
        let flat = store.noParticles && kind.isPoster
        Group {
            if flat {
                Rectangle().fill(options.tint.resolved(dark: dark).opacity(0.16))
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / 30, paused: still)) { ctx in
                    let t = still ? 9 : ctx.date.timeIntervalSince(AppClock.start)
                    Canvas { gc, size in
                        let w = Double(size.width), h = Double(size.height)
                        guard w > 0, h > 0 else { return }
                        if kind.isPoster {
                            gc.fill(Path(CGRect(origin: .zero, size: size)), with: .color(options.tint.resolved(dark: dark).opacity(0.1)))
                        }
                        sim.setup(kind, seed: seed, w: w, h: h)
                        sim.draw(gc, kind: kind, w: w, h: h, t: t, still: still, o: options, dark: dark)
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }
}
