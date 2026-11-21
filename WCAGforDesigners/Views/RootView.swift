import SwiftUI

/// Chooses the layout from the window, not the device name:
/// - narrower than 460 pt (a regular iPhone in portrait): bottom tab bar, one column, standard navigation.
/// - 460 pt and wider (iPhone Duo cover and inner screens, landscape, iPad): one vertical control bar on the
///   physical right edge, per Apple's vertical-controls guidance for the Duo. It never flips in right-to-left.
/// - 700 pt and wider: every screen becomes a two-page spread split at the fold.
struct RootView: View {
    @Environment(AppStore.self) var store
    @Environment(\.scenePhase) var phase

    static let railWidth: CGFloat = 60

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let rail = w >= 460
            let spread = w >= 700
            content(width: w, trailingInset: geo.safeAreaInsets.trailing, rail: rail, spread: spread)
        }
        .environment(\.uiScale, CGFloat(store.textScale))
        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
        .tint(T.ink)
        .onAppear { store.theme.apply() }
        .onChange(of: phase) { _, p in
            if p == .active { store.refreshClock(); store.theme.apply() }
        }
    }

    @ViewBuilder
    private func content(width w: CGFloat, trailingInset: CGFloat, rail: Bool, spread: Bool) -> some View {
        let dir: LayoutDirection = store.mirror ? .rightToLeft : .leftToRight
        if store.showPlacement {
            OnboardingView()
                .environment(\.layout, LayoutInfo(spread: spread, firstPageWidth: floor(w / 2), rail: false))
                .environment(\.layoutDirection, dir)
                .background(PaperBackground())
        } else if rail {
            // The rail lives in the trailing safe-area strip (where the status bar sits in this
            // orientation) rather than beside it, and only takes room from the page when that
            // strip is narrower than the rail itself.
            let railW = max(Self.railWidth, trailingInset)
            let taken = railW - trailingInset
            let first = floor(store.mirror ? w / 2 - taken : w / 2)
            ZStack(alignment: .bottom) {
                railScreen
                    .id(store.tab)
                ToastView(spread: spread)
            }
            .environment(\.layout, LayoutInfo(spread: spread, firstPageWidth: first, rail: true))
            .environment(\.layoutDirection, dir)
            .padding(.trailing, taken)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                RailBar()
                    .frame(width: railW)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .environment(\.layoutDirection, dir)
                    .ignoresSafeArea(.container, edges: .trailing)
            }
            .background(PaperBackground())
            .environment(\.layoutDirection, .leftToRight)
        } else {
            TabsShell()
                .environment(\.layout, LayoutInfo(spread: false, firstPageWidth: w, rail: false))
                .environment(\.layoutDirection, dir)
        }
    }

    @ViewBuilder
    private var railScreen: some View {
        if let top = store.currentStack.last {
            Destination(route: top)
        } else {
            TabRoot(tab: store.tab)
        }
    }
}

/// The root view of each tab.
struct TabRoot: View {
    let tab: AppTab
    var body: some View {
        switch tab {
        case .today: TodayView()
        case .learn: LearnView()
        case .practice: PracticeView()
        case .you: YouView()
        }
    }
}

/// Screens reached by navigating.
struct Destination: View {
    let route: Route
    var body: some View {
        switch route {
        case .principle(let i): PrincipleView(index: i)
        case .criterion(let n): CriterionView(num: n)
        }
    }
}

// MARK: - Regular iPhone: bottom tab bar

struct TabsShell: View {
    @Environment(AppStore.self) var store

    var body: some View {
        TabView(selection: Binding(get: { store.tab }, set: { store.tab = $0 })) {
            ForEach(AppTab.allCases, id: \.self) { t in
                NavigationStack(path: store.stackBinding(t)) {
                    TabRoot(tab: t)
                        .background(PaperBackground())
                        .toolbar(.hidden, for: .navigationBar)
                        .navigationDestination(for: Route.self) { r in
                            Destination(route: r)
                                .background(PaperBackground())
                                .navigationBarTitleDisplayMode(.inline)
                        }
                }
                .tabItem { Label(t.label, systemImage: t.symbol) }
                .tag(t)
            }
        }
        .overlay(alignment: .bottom) {
            ToastView(spread: false).padding(.bottom, 64)
        }
    }
}

// MARK: - iPhone Duo and wider: vertical control bar on the right edge

struct RailBar: View {
    @Environment(AppStore.self) var store

    var body: some View {
        VStack(spacing: 10) {
            // Controls stack from the bottom so the top of the strip stays clear for the status bar.
            Spacer(minLength: 0)
            if !store.currentStack.isEmpty {
                circle("chevron.backward", label: "Back") { store.back() }
            }
            if case .criterion(let n)? = store.currentStack.last {
                let on = store.isLearned(n)
                let tint = WCAG.criterion(n).principle.tint.color
                Button { store.toggleLearned(n) } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(on ? T.onInk : T.ink)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(on ? tint : Color.clear))
                        .overlay(Circle().strokeBorder(tint, lineWidth: 1))
                }
                .buttonStyle(PressStyle())
                .accessibilityLabel(on ? "Learned — lit on your map" : "Mark as learned")
                .accessibilityAddTraits(on ? [.isSelected] : [])
            }
            VStack(spacing: 4) {
                ForEach(AppTab.allCases, id: \.self) { t in
                    let on = store.tab == t
                    Button { store.select(t) } label: {
                        Image(systemName: on ? t.selectedSymbol : t.symbol)
                            .font(.system(size: 19, weight: on ? .semibold : .regular))
                            .foregroundStyle(on ? T.onInk : T.body)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(on ? T.ink : Color.clear))
                    }
                    .buttonStyle(PressStyle())
                    .accessibilityLabel(t.label)
                    .accessibilityAddTraits(on ? [.isSelected, .isButton] : [.isButton])
                }
            }
            .padding(4)
            .background(Capsule().fill(T.card))
            .overlay(Capsule().strokeBorder(T.line, lineWidth: 1))
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Main")
        }
        .padding(.top, 12)
        .padding(.bottom, 22)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func circle(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(T.ink)
                .frame(width: 44, height: 44)
                .background(Circle().fill(T.card))
                .overlay(Circle().strokeBorder(T.line2, lineWidth: 1))
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(label)
    }
}

// MARK: - Toast

struct ToastView: View {
    let spread: Bool
    @Environment(AppStore.self) var store

    var body: some View {
        if let msg = store.toast {
            Text(msg)
                .face(.sansBold, 15, lineHeight: 1.4)
                .foregroundStyle(T.bg)
                .padding(.horizontal, 18).padding(.vertical, 14)
                .frame(maxWidth: spread ? CGFloat(380) : CGFloat.infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 18).fill(T.ink))
                .shadow(color: Color(rgb: 0x3C2D14, opacity: 0.2), radius: 20, y: 14)
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity, alignment: spread ? .trailing : .center)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .accessibilityAddTraits(.updatesFrequently)
                .onAppear { UIAccessibility.post(notification: .announcement, argument: msg) }
        }
    }
}
