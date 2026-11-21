# WCAG for Designers — iOS

Native SwiftUI app built from `project/WCAG for Designers iOS.dc.html` (the Claude Design handoff).
No third-party dependencies.

## Run it on your iPhone

You need a Mac with **Xcode 16 or newer** and an Apple ID.

1. Open `ios/WCAGforDesigners.xcodeproj` in Xcode.
2. Select the **WCAGforDesigners** target → **Signing & Capabilities**.
   - Tick **Automatically manage signing** (already on).
   - **Team:** choose your Apple ID. If it isn't listed, add it under Xcode → Settings → Accounts.
   - If Xcode says the bundle ID is taken, change `app.wcagfordesigners.ios` to something unique, such as `com.yourname.wcagfordesigners`.
3. Plug in your iPhone (or pair it over Wi-Fi), then pick it in the device menu at the top of the window.
4. On the iPhone, turn on **Developer Mode**: Settings → Privacy & Security → Developer Mode. The phone restarts.
5. Press **Run** (⌘R).
6. The first time, iOS blocks the app until you trust the developer: Settings → General → VPN & Device Management → your Apple ID → Trust.

With a free Apple ID, the app stops opening after 7 days; press Run again to reinstall it. A paid developer account removes that limit and lets you use TestFlight.

To try other sizes without a device, run it on a simulator: an iPhone in portrait (bottom tab bar), an iPhone in landscape or an iPad (right-edge bar and two-page spreads).

## How the layout adapts

The design targets the foldable iPhone Duo (cover 466 × 678 pt, open 951 × 669 pt). The app chooses its layout from the **window width**, so it works on any iPhone, the Duo, and iPad:

| Window width | Navigation | Pages |
|---|---|---|
| under 460 pt (regular iPhone, portrait) | Standard bottom tab bar and back button | One column |
| 460 pt and up (Duo cover screen) | One 60 pt vertical bar on the physical right edge: Back and lesson actions at the top, icon tabs at the bottom. It stays on the right in mirrored (RTL) layout. | One column |
| 700 pt and up (Duo open, iPhone landscape, iPad) | Same right-edge bar | Two-page spread split at the fold; each page scrolls on its own. A lesson is read on the left, with the demo and quick check on the right. |

A regular iPhone gets the standard bottom tab bar because that is Apple's guidance for those screens. The right-edge bar follows the vertical-controls rule the design used for the Duo.

## What's in it

- **Placement:** scope, then 6 questions, which place you on the knowledge × scope matrix. It sets lesson depth, path and practice task.
- **Today:** today's lesson poster, review due, the 86-dot WCAG map and your path.
- **Learn:** six paths, the Atlas (4 principles → 13 guidelines → 86 criteria) with level filters, the three levels and the law map.
- **Lessons:** all 86 WCAG 2.2 criteria, each with a full See it / Apply it / Lead it lesson and a quick check. 4 lessons have interactive demos: contrast slider, colour-blindness simulation, simulated taps on a target, and parallax with a Reduce motion switch.
- **Practice:** spaced review (1, 3, 7, 21, 60 days), Name it (8 scenarios), and a task for your scope.
- **You:** local profile, scope, appearance (Auto / Light / Dark), text size (100 / 115 / 130 %, on top of iOS Dynamic Type), Reduce motion, Hide particles, Mirror layout.
- **Account:** log in / sign up with Google, Apple, Microsoft, GitHub or email, plus a profile. **These are local only for now:** they create a profile stored on the phone and nothing is sent anywhere.

Progress, placement, settings and the profile are saved on the device in `UserDefaults`.

## Accessibility

- Text scales with iOS Dynamic Type (capped at Accessibility 3) and with the in-app text size.
- Every poster and demo canvas is hidden from VoiceOver. Map dots, tabs, chips and switches have labels, traits and values.
- Animation stops when Reduce Motion is on in iOS or in the app.
- Supports portrait and landscape (WCAG 1.3.4).
- Tap targets are 44 pt, except the map dots (24 pt), which meet 2.5.8.

## Project layout

```
content/                 lesson copy, shared by iOS, web and Electron
  wcag.json              principles, guidelines, the 86 criteria
  app.json               paths, practice scenarios, scope tasks, placement questions, laws
  lessons/<num>.json     one full lesson per criterion
tools/gen-content.js     validates content/ and generates Library.swift
WCAGforDesigners.xcodeproj
WCAGforDesigners/
  App/          entry point
  Model/        Library.swift (generated, do not edit), Models.swift, AppStore.swift (state + persistence)
  Design/       Theme (colours, fonts), Components, Particles (poster and demo engine)
  Views/        Root (layout + rail), Today, Learn, Criterion, Demos, Practice, You, Account, Onboarding
  Resources/Fonts   Newsreader, Hanken Grotesk, JetBrains Mono (static instances, SIL OFL)
  Assets.xcassets   App icon (placeholder) and accent colour
licenses/       font licences
```

The project uses Xcode 16's folder-synchronised groups: new files dropped into `WCAGforDesigners/` are picked up automatically.

### Editing lesson content

Edit the JSON in `content/`, then from the repository root:

```
node tools/gen-content.js           # validate and regenerate Library.swift
node tools/gen-content.js --check   # validate only, and list which path lessons are missing
```

The check rejects a lesson with missing fields, a quiz without exactly three options, or a criterion number that isn't in WCAG 2.2.

## Known gaps

- Sign-in is local; the platform buttons use letter monograms until the official logos are added.
- The app icon is a placeholder.
- "WCAG" is a W3C trademark. Check the name before you submit to the App Store.
