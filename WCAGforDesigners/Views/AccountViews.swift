import SwiftUI

enum AccountSheet: String, Identifiable {
    case login, signup, profile
    var id: String { rawValue }
}

private struct Platform: Identifiable {
    let name: String
    let mono: String
    var id: String { name }
}

/// Monogram placeholders until the official logos are added.
private let platforms = [Platform(name: "Google", mono: "G"), Platform(name: "Apple", mono: "A"),
                         Platform(name: "Microsoft", mono: "M"), Platform(name: "GitHub", mono: "GH")]

/// Log in / sign up and the profile, styled as the landing page's index-card dialog.
/// Accounts are local to this device for now: every path creates or edits a profile stored on the phone.
struct AccountSheetView: View {
    @Environment(AppStore.self) var store
    @Environment(\.dismiss) var dismiss
    @State var mode: AccountSheet
    @State var name = ""
    @State var email = ""
    @State var password = ""
    @State var errors: [String: String] = [:]
    @FocusState var focus: String?

    init(initial: AccountSheet) { _mode = State(initialValue: initial) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(mode == .profile ? "YOUR PROFILE" : "ACCOUNT").kicker(T.accent, size: 13, tracking: 0.08)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 15, weight: .semibold)).foregroundStyle(T.ink)
                            .frame(width: 44, height: 44)
                            .overlay(Circle().strokeBorder(T.muted, lineWidth: 1))
                    }
                    .buttonStyle(PressStyle())
                    .accessibilityLabel("Close")
                }
                .padding(.bottom, 10)
                .overlay(alignment: .bottom) { Rectangle().fill(T.accent).frame(height: 1) }

                if mode == .profile, let a = store.account {
                    profile(a)
                } else {
                    auth
                }
            }
            .padding(.horizontal, 26).padding(.top, 16).padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(T.card)
        .presentationDetents([.large])
        .presentationCornerRadius(6)
    }

    // MARK: Log in / sign up

    @ViewBuilder private var auth: some View {
        let signup = mode == .signup
        Headline(text: signup ? "Create your account" : "Welcome back", size: 44)
        HStack(spacing: 6) {
            tab(.login, "Log in")
            tab(.signup, "Sign up")
        }
        .padding(5)
        .background(Capsule().fill(T.bg))
        .overlay(Capsule().strokeBorder(T.line, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Log in or sign up")

        VStack(alignment: .leading, spacing: 10) {
            Text("CONTINUE WITH").kicker(size: 13, tracking: 0.08)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(platforms) { p in
                    Button { signIn(via: p.name) } label: {
                        HStack(spacing: 10) {
                            Text(p.mono).face(.monoSemibold, 12).foregroundStyle(T.ink)
                                .frame(width: 30, height: 30)
                                .overlay(Circle().strokeBorder(T.muted, lineWidth: 1))
                                .accessibilityHidden(true)
                            Text(p.name).face(.sansBold, 16).foregroundStyle(T.ink).lineLimit(1).minimumScaleFactor(0.8)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 12)
                        .frame(minHeight: 52)
                        .background(RoundedRectangle(cornerRadius: 12).fill(T.bg))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(T.line2, lineWidth: 1))
                    }
                    .buttonStyle(PressStyle())
                    .accessibilityLabel("Continue with \(p.name)")
                }
            }
            Text("Accounts stay on this iPhone for now. Platform sign-in connects once syncing is ready.")
                .face(.sans, 13, lineHeight: 1.4).foregroundStyle(T.muted)
                .fixedSize(horizontal: false, vertical: true)
        }

        HStack(spacing: 12) {
            Rectangle().fill(T.line2).frame(height: 1)
            Text("OR WITH EMAIL").kicker(size: 13, tracking: 0.08).fixedSize()
            Rectangle().fill(T.line2).frame(height: 1)
        }
        .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 16) {
            if signup {
                field("name", "Name", text: $name, content: .name, keyboard: .default)
            }
            field("email", "Email", text: $email, content: .emailAddress, keyboard: .emailAddress)
            field("pw", "Password", text: $password, content: signup ? .newPassword : .password, keyboard: .default,
                  secure: true, hint: signup ? "At least 8 characters." : nil)
            Button(signup ? "Create account" : "Log in") { submit() }
                .buttonStyle(PillButtonStyle(fill: T.accent, onFill: T.bg, height: 56))
                .padding(.top, 4)
        }

        HStack(spacing: 6) {
            Text(signup ? "Already have an account?" : "New here?").face(.sans, 15).foregroundStyle(T.body)
            Button(signup ? "Log in" : "Sign up") { switchMode(signup ? .login : .signup) }
                .face(.sansBold, 15).foregroundStyle(T.ink).underline()
                .frame(minHeight: 44)
        }
    }

    private func tab(_ m: AccountSheet, _ label: String) -> some View {
        let on = mode == m
        return Button { switchMode(m) } label: {
            Text(label).face(.sansBold, 15).foregroundStyle(on ? T.onInk : T.ink)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Capsule().fill(on ? T.ink : Color.clear))
                .contentShape(Capsule())
        }
        .buttonStyle(PressStyle())
        .accessibilityAddTraits(on ? [.isSelected] : [])
    }

    private func field(_ key: String, _ label: String, text: Binding<String>, content: UITextContentType,
                       keyboard: UIKeyboardType, secure: Bool = false, hint: String? = nil) -> some View {
        let err = errors[key]
        return VStack(alignment: .leading, spacing: 6) {
            Text(label).face(.sansBold, 15).foregroundStyle(T.ink)
            if let hint { Text(hint).face(.sans, 14).foregroundStyle(T.muted) }
            Group {
                if secure { SecureField("", text: text) } else { TextField("", text: text) }
            }
            .textContentType(content)
            .keyboardType(keyboard)
            .textInputAutocapitalization(key == "name" ? .words : .never)
            .autocorrectionDisabled()
            .focused($focus, equals: key)
            .face(.sans, 16)
            .foregroundStyle(T.ink)
            .padding(.horizontal, 16)
            .frame(minHeight: 52)
            .background(RoundedRectangle(cornerRadius: 14).fill(T.bg))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(err == nil ? T.muted : T.rust, lineWidth: 1))
            .accessibilityLabel(label)
            .accessibilityHint([hint, err].compactMap { $0 }.joined(separator: ". "))
            if let err {
                HStack(spacing: 8) {
                    Text("✕").accessibilityHidden(true)
                    Text(err)
                }
                .face(.sansBold, 14).foregroundStyle(T.rust)
            }
        }
    }

    private func switchMode(_ m: AccountSheet) {
        mode = m
        errors = [:]
    }

    private func submit() {
        var e: [String: String] = [:]
        let signup = mode == .signup
        let mail = email.trimmingCharacters(in: .whitespaces)
        if signup && name.trimmingCharacters(in: .whitespaces).isEmpty { e["name"] = "Enter your name." }
        if mail.range(of: #"^\S+@\S+\.\S+$"#, options: .regularExpression) == nil { e["email"] = "Enter an email address, like name@studio.com." }
        if signup ? password.count < 8 : password.isEmpty { e["pw"] = signup ? "Use at least 8 characters." : "Enter your password." }
        errors = e
        if let first = (signup ? ["name", "email", "pw"] : ["email", "pw"]).first(where: { e[$0] != nil }) {
            focus = first
            UIAccessibility.post(notification: .announcement, argument: e[first] ?? "")
            return
        }
        signIn(via: "Email")
    }

    private func signIn(via: String) {
        let mail = email.trimmingCharacters(in: .whitespaces)
        let typed = name.trimmingCharacters(in: .whitespaces)
        let display = !typed.isEmpty ? typed : (via == "Email" && !mail.isEmpty ? String(mail.split(separator: "@").first ?? "") : "")
        store.signIn(name: display, email: mail, via: via)
        password = ""
        mode = .profile
        focus = display.isEmpty ? "profileName" : nil
    }

    // MARK: Profile

    @ViewBuilder private func profile(_ a: Account) -> some View {
        HStack(spacing: 18) {
            Text(a.initials).face(.serifItalic, 34).foregroundStyle(T.bg)
                .frame(width: 76, height: 76)
                .background(Circle().fill(T.accent))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                Headline(text: a.name.trimmingCharacters(in: .whitespaces).isEmpty ? "Your name" : a.name, size: 40)
                if !a.email.isEmpty { Text(a.email).face(.mono, 13).foregroundStyle(T.muted) }
                Text("✓ " + (a.via == "Email" ? "EMAIL" : a.via.uppercased()))
                    .face(.monoSemibold, 13, tracking: 0.06).foregroundStyle(T.green)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(T.green, lineWidth: 1.5))
                    .rotationEffect(.degrees(-2))
                    .padding(.top, 2)
            }
        }

        VStack(alignment: .leading, spacing: 6) {
            Text("Display name").face(.sansBold, 15).foregroundStyle(T.ink)
            TextField("", text: Binding(get: { store.account?.name ?? "" }, set: { v in store.updateAccount { $0.name = v } }))
                .textContentType(.name)
                .focused($focus, equals: "profileName")
                .face(.sans, 16).foregroundStyle(T.ink)
                .padding(.horizontal, 16).frame(minHeight: 52)
                .background(RoundedRectangle(cornerRadius: 14).fill(T.bg))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(T.muted, lineWidth: 1))
                .accessibilityLabel("Display name")
        }

        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR SCOPE").kicker(size: 13, tracking: 0.08)
            FlowLayout(spacing: 8, lineSpacing: 8) {
                ForEach(Library.roles) { r in
                    Chip(label: r.id, on: store.role == r.id, size: 15) { store.setRole(r.id) }
                }
            }
            Para(text: "\(store.level) knowledge, \(store.role) scope. Lessons open on “\(store.defaultDepth.label)”. Knowledge is set by the placement questions.", size: 15)
        }

        VStack(alignment: .leading, spacing: 0) {
            Text("SIGN-IN METHODS").kicker(size: 13, tracking: 0.08).padding(.bottom, 8)
            ForEach(platforms) { p in
                let on = a.links[p.name] == true
                HStack(spacing: 12) {
                    Text(p.mono).face(.monoSemibold, 12).foregroundStyle(T.ink)
                        .frame(width: 30, height: 30).overlay(Circle().strokeBorder(T.muted, lineWidth: 1))
                        .accessibilityHidden(true)
                    Text(p.name).face(.sansMedium, 16).foregroundStyle(T.ink).frame(maxWidth: .infinity, alignment: .leading)
                    Button(on ? "✓ Connected" : "Connect") { store.updateAccount { $0.links[p.name] = !on } }
                        .face(.sansBold, 14)
                        .foregroundStyle(on ? T.green : T.ink)
                        .padding(.horizontal, 16).frame(minHeight: 44)
                        .background(Capsule().fill(on ? T.chip : Color.clear))
                        .overlay(Capsule().strokeBorder(on ? T.green : T.mute2, lineWidth: 1))
                        .accessibilityLabel((on ? "Disconnect " : "Connect ") + p.name)
                }
                .frame(minHeight: 60)
                .overlay(alignment: .top) { Rectangle().fill(T.line).frame(height: 1) }
            }
        }

        Button("Log out") {
            store.signOut()
            dismiss()
        }
        .buttonStyle(PillButtonStyle(border: T.muted, height: 56))
    }
}
