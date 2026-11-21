// GENERATED from "WCAG for Designers iOS.dc.html" by tools/gen-content.js — do not edit by hand.
// Lesson copy lives here so the iOS, web and Electron builds can share one source later.
import Foundation

enum Library {
    static let principles: [Principle] = [
        Principle(n: 1, id: "P", name: "Perceivable", question: "Can people perceive it?", desc: "Information and interface components must be presentable in ways people can perceive — whichever senses they rely on."),
        Principle(n: 2, id: "O", name: "Operable", question: "Can people operate it?", desc: "Components and navigation must work for everyone — by keyboard, touch, voice or switch — with enough time and without harm."),
        Principle(n: 3, id: "U", name: "Understandable", question: "Can people understand it?", desc: "Content and behavior must be readable, predictable, and forgiving of mistakes."),
        Principle(n: 4, id: "R", name: "Robust", question: "Will it work with assistive tech?", desc: "Content must be built so browsers and assistive technologies can interpret it reliably — today and as they evolve."),
    ]

    static let guidelines: [Guideline] = [
        Guideline(num: "1.1", name: "Text Alternatives", summary: "Provide text alternatives for any non-text content."),
        Guideline(num: "1.2", name: "Time-based Media", summary: "Provide alternatives for audio and video."),
        Guideline(num: "1.3", name: "Adaptable", summary: "Create content that can be presented in different ways without losing structure."),
        Guideline(num: "1.4", name: "Distinguishable", summary: "Make it easier to see and hear content, including separating foreground from background."),
        Guideline(num: "2.1", name: "Keyboard Accessible", summary: "Make all functionality available from a keyboard."),
        Guideline(num: "2.2", name: "Enough Time", summary: "Give people enough time to read and use content."),
        Guideline(num: "2.3", name: "Seizures and Physical Reactions", summary: "Don’t design content in ways known to cause seizures or physical reactions."),
        Guideline(num: "2.4", name: "Navigable", summary: "Help people navigate, find content, and know where they are."),
        Guideline(num: "2.5", name: "Input Modalities", summary: "Make it easier to operate functionality through inputs beyond the keyboard."),
        Guideline(num: "3.1", name: "Readable", summary: "Make text readable and understandable."),
        Guideline(num: "3.2", name: "Predictable", summary: "Make pages appear and operate in predictable ways."),
        Guideline(num: "3.3", name: "Input Assistance", summary: "Help people avoid and correct mistakes."),
        Guideline(num: "4.1", name: "Compatible", summary: "Maximize compatibility with current and future tools, including assistive technologies."),
    ]

    static let newIn22: Set<String> = ["2.4.11", "2.4.12", "2.4.13", "2.5.7", "2.5.8", "3.2.6", "3.3.7", "3.3.8", "3.3.9"]

    static let criteria: [Criterion] = [
        Criterion(num: "1.1.1", title: "Non-text Content", level: .a, designerLed: true, summary: "Every meaningful image, icon and control has a text alternative. Decorative ones are hidden from assistive tech."),
        Criterion(num: "1.2.1", title: "Audio-only and Video-only (Prerecorded)", level: .a, designerLed: false, summary: "Audio-only and video-only recordings come with a transcript or an equivalent alternative."),
        Criterion(num: "1.2.2", title: "Captions (Prerecorded)", level: .a, designerLed: false, summary: "Prerecorded video with sound has synchronized captions."),
        Criterion(num: "1.2.3", title: "Audio Description or Media Alternative (Prerecorded)", level: .a, designerLed: false, summary: "Prerecorded video has audio description or a full text alternative."),
        Criterion(num: "1.2.4", title: "Captions (Live)", level: .aa, designerLed: false, summary: "Live video with sound has captions."),
        Criterion(num: "1.2.5", title: "Audio Description (Prerecorded)", level: .aa, designerLed: false, summary: "Prerecorded video describes important visual information in audio."),
        Criterion(num: "1.2.6", title: "Sign Language (Prerecorded)", level: .aaa, designerLed: false, summary: "Prerecorded video includes sign language interpretation."),
        Criterion(num: "1.2.7", title: "Extended Audio Description (Prerecorded)", level: .aaa, designerLed: false, summary: "Video pauses for longer descriptions when natural gaps are too short."),
        Criterion(num: "1.2.8", title: "Media Alternative (Prerecorded)", level: .aaa, designerLed: false, summary: "Prerecorded media has a full text alternative."),
        Criterion(num: "1.2.9", title: "Audio-only (Live)", level: .aaa, designerLed: false, summary: "Live audio-only content has a text alternative, such as live captions."),
        Criterion(num: "1.3.1", title: "Info and Relationships", level: .a, designerLed: true, summary: "Structure you show visually — headings, lists, tables, groups — also exists in code."),
        Criterion(num: "1.3.2", title: "Meaningful Sequence", level: .a, designerLed: true, summary: "When order affects meaning, the reading order in code matches it."),
        Criterion(num: "1.3.3", title: "Sensory Characteristics", level: .a, designerLed: true, summary: "Instructions don’t rely only on shape, size, position or sound — not just “tap the round button on the right”."),
        Criterion(num: "1.3.4", title: "Orientation", level: .aa, designerLed: true, summary: "Content works in both portrait and landscape, unless one orientation is essential."),
        Criterion(num: "1.3.5", title: "Identify Input Purpose", level: .aa, designerLed: true, summary: "Fields that collect personal details are identified, so browsers can autofill them."),
        Criterion(num: "1.3.6", title: "Identify Purpose", level: .aaa, designerLed: false, summary: "The purpose of components, icons and regions can be determined by software."),
        Criterion(num: "1.4.1", title: "Use of Color", level: .a, designerLed: true, summary: "Color is never the only way you show information, prompt an action, or mark an element."),
        Criterion(num: "1.4.2", title: "Audio Control", level: .a, designerLed: false, summary: "Audio that plays automatically for more than 3 seconds can be paused or muted."),
        Criterion(num: "1.4.3", title: "Contrast (Minimum)", level: .aa, designerLed: true, summary: "Text has a contrast ratio of at least 4.5:1 with its background — or 3:1 when it’s large."),
        Criterion(num: "1.4.4", title: "Resize Text", level: .aa, designerLed: true, summary: "Text can be resized to 200% without losing content or function."),
        Criterion(num: "1.4.5", title: "Images of Text", level: .aa, designerLed: true, summary: "Use real text rather than images of text, except for logos."),
        Criterion(num: "1.4.6", title: "Contrast (Enhanced)", level: .aaa, designerLed: true, summary: "Text has a contrast ratio of at least 7:1 — or 4.5:1 when it’s large."),
        Criterion(num: "1.4.7", title: "Low or No Background Audio", level: .aaa, designerLed: false, summary: "Speech recordings have little or no background sound."),
        Criterion(num: "1.4.8", title: "Visual Presentation", level: .aaa, designerLed: true, summary: "Text blocks can be adjusted: under 80 characters wide, not justified, generous line spacing."),
        Criterion(num: "1.4.9", title: "Images of Text (No Exception)", level: .aaa, designerLed: true, summary: "Images of text are used only for decoration, or where the presentation is essential."),
        Criterion(num: "1.4.10", title: "Reflow", level: .aa, designerLed: true, summary: "Content reflows to a 320px-wide viewport without scrolling in two directions."),
        Criterion(num: "1.4.11", title: "Non-text Contrast", level: .aa, designerLed: true, summary: "Icons, field borders, focus indicators and meaningful graphics have at least 3:1 contrast."),
        Criterion(num: "1.4.12", title: "Text Spacing", level: .aa, designerLed: true, summary: "Nothing breaks when people increase line, paragraph, letter and word spacing."),
        Criterion(num: "1.4.13", title: "Content on Hover or Focus", level: .aa, designerLed: true, summary: "Tooltips and popovers that appear on hover or focus can be dismissed, hovered over, and stay put."),
        Criterion(num: "2.1.1", title: "Keyboard", level: .a, designerLed: true, summary: "Everything can be operated with a keyboard alone."),
        Criterion(num: "2.1.2", title: "No Keyboard Trap", level: .a, designerLed: false, summary: "Keyboard focus never gets stuck inside a component."),
        Criterion(num: "2.1.3", title: "Keyboard (No Exception)", level: .aaa, designerLed: false, summary: "Everything can be operated with a keyboard — with no exceptions."),
        Criterion(num: "2.1.4", title: "Character Key Shortcuts", level: .a, designerLed: false, summary: "Single-key shortcuts can be turned off or remapped."),
        Criterion(num: "2.2.1", title: "Timing Adjustable", level: .a, designerLed: true, summary: "Time limits can be turned off, adjusted or extended."),
        Criterion(num: "2.2.2", title: "Pause, Stop, Hide", level: .a, designerLed: true, summary: "Moving, blinking or auto-updating content can be paused, stopped or hidden."),
        Criterion(num: "2.2.3", title: "No Timing", level: .aaa, designerLed: true, summary: "Timing isn’t an essential part of the activity."),
        Criterion(num: "2.2.4", title: "Interruptions", level: .aaa, designerLed: true, summary: "Interruptions such as alerts and updates can be postponed or turned off."),
        Criterion(num: "2.2.5", title: "Re-authenticating", level: .aaa, designerLed: false, summary: "When a session expires, people can sign back in and continue without losing data."),
        Criterion(num: "2.2.6", title: "Timeouts", level: .aaa, designerLed: true, summary: "People are told how long they can be inactive before data is lost."),
        Criterion(num: "2.3.1", title: "Three Flashes or Below Threshold", level: .a, designerLed: true, summary: "Nothing flashes more than three times in any one second."),
        Criterion(num: "2.3.2", title: "Three Flashes", level: .aaa, designerLed: true, summary: "Nothing flashes more than three times per second — no threshold exception."),
        Criterion(num: "2.3.3", title: "Animation from Interactions", level: .aaa, designerLed: true, summary: "Motion triggered by interaction can be turned off, unless it’s essential."),
        Criterion(num: "2.4.1", title: "Bypass Blocks", level: .a, designerLed: true, summary: "There’s a way to skip blocks that repeat on every page, like navigation."),
        Criterion(num: "2.4.2", title: "Page Titled", level: .a, designerLed: true, summary: "Every page or screen has a title that describes its topic or purpose."),
        Criterion(num: "2.4.3", title: "Focus Order", level: .a, designerLed: true, summary: "Focus moves through the page in an order that preserves meaning."),
        Criterion(num: "2.4.4", title: "Link Purpose (In Context)", level: .a, designerLed: true, summary: "The purpose of each link is clear from its text, together with its context."),
        Criterion(num: "2.4.5", title: "Multiple Ways", level: .aa, designerLed: true, summary: "There’s more than one way to find a page — search, navigation, a sitemap."),
        Criterion(num: "2.4.6", title: "Headings and Labels", level: .aa, designerLed: true, summary: "Headings and labels describe their topic or purpose."),
        Criterion(num: "2.4.7", title: "Focus Visible", level: .aa, designerLed: true, summary: "Keyboard focus is always visible."),
        Criterion(num: "2.4.8", title: "Location", level: .aaa, designerLed: true, summary: "People can tell where they are — breadcrumbs, current-page states, step indicators."),
        Criterion(num: "2.4.9", title: "Link Purpose (Link Only)", level: .aaa, designerLed: true, summary: "The purpose of each link is clear from the link text alone."),
        Criterion(num: "2.4.10", title: "Section Headings", level: .aaa, designerLed: true, summary: "Content is organized with section headings."),
        Criterion(num: "2.4.11", title: "Focus Not Obscured (Minimum)", level: .aa, designerLed: true, summary: "A focused element is never completely hidden by sticky headers, banners or overlays."),
        Criterion(num: "2.4.12", title: "Focus Not Obscured (Enhanced)", level: .aaa, designerLed: true, summary: "No part of a focused element is hidden by content you created."),
        Criterion(num: "2.4.13", title: "Focus Appearance", level: .aaa, designerLed: true, summary: "Focus indicators are big and bold: at least as large as a 2px outline, with 3:1 contrast against the unfocused state."),
        Criterion(num: "2.5.1", title: "Pointer Gestures", level: .a, designerLed: true, summary: "Multi-finger and path-based gestures have a single-pointer alternative."),
        Criterion(num: "2.5.2", title: "Pointer Cancellation", level: .a, designerLed: false, summary: "Actions fire on release, so people can slide off a target to cancel."),
        Criterion(num: "2.5.3", title: "Label in Name", level: .a, designerLed: true, summary: "A control’s accessible name contains the text of its visible label."),
        Criterion(num: "2.5.4", title: "Motion Actuation", level: .a, designerLed: true, summary: "Shake and tilt actions have an on-screen alternative and can be turned off."),
        Criterion(num: "2.5.5", title: "Target Size (Enhanced)", level: .aaa, designerLed: true, summary: "Pointer targets are at least 44 by 44 CSS pixels."),
        Criterion(num: "2.5.6", title: "Concurrent Input Mechanisms", level: .aaa, designerLed: false, summary: "People can switch between touch, mouse, keyboard and other inputs at any time."),
        Criterion(num: "2.5.7", title: "Dragging Movements", level: .aa, designerLed: true, summary: "Anything done by dragging can also be done with single taps or clicks."),
        Criterion(num: "2.5.8", title: "Target Size (Minimum)", level: .aa, designerLed: true, summary: "Pointer targets are at least 24 by 24 CSS pixels — or spaced far enough from each other."),
        Criterion(num: "3.1.1", title: "Language of Page", level: .a, designerLed: false, summary: "The page’s main language is set in code, so screen readers pronounce it correctly."),
        Criterion(num: "3.1.2", title: "Language of Parts", level: .aa, designerLed: false, summary: "Passages in a different language are marked up as such."),
        Criterion(num: "3.1.3", title: "Unusual Words", level: .aaa, designerLed: true, summary: "Jargon, idioms and unusual words have definitions available."),
        Criterion(num: "3.1.4", title: "Abbreviations", level: .aaa, designerLed: true, summary: "Abbreviations can be expanded or explained."),
        Criterion(num: "3.1.5", title: "Reading Level", level: .aaa, designerLed: true, summary: "Text above lower-secondary reading level comes with a simpler version or supplement."),
        Criterion(num: "3.1.6", title: "Pronunciation", level: .aaa, designerLed: false, summary: "Pronunciation is available where meaning depends on it."),
        Criterion(num: "3.2.1", title: "On Focus", level: .a, designerLed: true, summary: "Moving focus onto an element never triggers a surprise change of context."),
        Criterion(num: "3.2.2", title: "On Input", level: .a, designerLed: true, summary: "Changing a setting doesn’t unexpectedly change context, unless people are told first."),
        Criterion(num: "3.2.3", title: "Consistent Navigation", level: .aa, designerLed: true, summary: "Navigation that repeats across pages stays in the same order."),
        Criterion(num: "3.2.4", title: "Consistent Identification", level: .aa, designerLed: true, summary: "Components that do the same thing are labeled the same way."),
        Criterion(num: "3.2.5", title: "Change on Request", level: .aaa, designerLed: true, summary: "Changes of context only happen when people ask for them."),
        Criterion(num: "3.2.6", title: "Consistent Help", level: .a, designerLed: true, summary: "Help — contact details, chat, FAQs — appears in the same place on every page."),
        Criterion(num: "3.3.1", title: "Error Identification", level: .a, designerLed: true, summary: "Errors are identified, and described to the person in text."),
        Criterion(num: "3.3.2", title: "Labels or Instructions", level: .a, designerLed: true, summary: "Inputs have labels or instructions."),
        Criterion(num: "3.3.3", title: "Error Suggestion", level: .aa, designerLed: true, summary: "When an error is detected and a fix is known, suggest it."),
        Criterion(num: "3.3.4", title: "Error Prevention (Legal, Financial, Data)", level: .aa, designerLed: true, summary: "Legal, financial and data submissions can be reversed, checked, or confirmed."),
        Criterion(num: "3.3.5", title: "Help", level: .aaa, designerLed: true, summary: "Context-sensitive help is available."),
        Criterion(num: "3.3.6", title: "Error Prevention (All)", level: .aaa, designerLed: true, summary: "Every submission can be reversed, checked, or confirmed."),
        Criterion(num: "3.3.7", title: "Redundant Entry", level: .a, designerLed: true, summary: "Don’t make people re-enter information they’ve already given in the same process."),
        Criterion(num: "3.3.8", title: "Accessible Authentication (Minimum)", level: .aa, designerLed: true, summary: "Logging in doesn’t require a memory test or puzzle — unless there’s an alternative such as paste, passkeys or a magic link."),
        Criterion(num: "3.3.9", title: "Accessible Authentication (Enhanced)", level: .aaa, designerLed: true, summary: "Logging in doesn’t require any cognitive test — not even recognizing objects or personal images."),
        Criterion(num: "4.1.2", title: "Name, Role, Value", level: .a, designerLed: true, summary: "Every component exposes its name, role and current state to assistive technologies."),
        Criterion(num: "4.1.3", title: "Status Messages", level: .aa, designerLed: true, summary: "Status messages are announced to assistive tech without moving focus."),
    ]

    static let lessons: [String: DeepLesson] = [
        "1.4.3": DeepLesson(
            meta: "6 min · interactive", demo: .contrast,
            who: ["Low vision", "Color vision deficiency", "Aging eyes", "Anyone in bright sunlight", "Cheap or dim screens"],
            takeaways: ["Body text needs 4.5:1. Large text — 24px regular, or about 18.7px bold — needs 3:1.", "Measure against the real background. Over gradients and photos, test the lightest spot behind the text.", "Never round up. 4.49:1 fails.", "Logos, purely decorative text and inactive (disabled) controls are exempt."],
            failures: ["Light gray helper, placeholder and caption text", "White text on light brand colors — sky blue, yellow, orange", "Text over photos with no overlay or scrim"],
            check: ["Sample text and background with a contrast checker such as WebAIM or Stark.", "Check every state: hover, pressed, selected, error.", "For text on images, test the lightest area behind it."],
            quiz: Quiz(question: "A 16px regular label in #949494 sits on white — 3.03:1. Does it pass?", options: ["Yes — it’s above 3:1", "No — body text needs 4.5:1", "Only at Level A"], answer: 1, why: "16px regular isn’t “large text”, so 4.5:1 applies. #767676 is the lightest gray that passes on white — worth memorizing."),
            spec: ["Write the color pair and its measured ratio next to each text style.", "Where text sits on an image, note the scrim or overlay it depends on.", "List every state with its own pair: hover, pressed, selected, error."],
            review: ["Which pairs here were measured, and which were judged by eye?", "What happens to this text in dark mode and in the error state?", "Does anything look disabled that is actually active?"],
            tradeoff: "The brand color fails on white? Keep the hue for large type, fills and graphics, and choose a darker step for body text. An exception for one team becomes the standard for all.",
            system: "Ship color tokens as approved pairs, not loose swatches. If a pair is not in the system, nobody has checked it.",
            pitch: "Low-contrast text is one of the most common failures audits find, and the cheapest to fix once, in tokens."
        ),
        "1.4.1": DeepLesson(
            meta: "5 min · interactive", demo: .color,
            who: ["Color vision deficiency — about 1 in 12 men", "Low vision", "Monochrome displays", "Screen glare"],
            takeaways: ["Pair every color cue with a second one: text, an icon, a pattern, a shape or position.", "Links inside body text need an underline — or 3:1 contrast with surrounding text plus a non-color cue on hover and focus.", "In charts, label lines and areas directly instead of relying on a color legend.", "Errors and required fields need words, not just red."],
            failures: ["Form errors shown only by a red border", "Red and green status dots with no label", "Line charts where series differ only by hue"],
            check: ["View the screen in grayscale. Is anything lost?", "Run it through a color-blindness simulator.", "For each color you use, ask: what else tells people this?"],
            quiz: Quiz(question: "Required fields are marked only by red labels. Which fix satisfies 1.4.1?", options: ["Make the red darker", "Add “(required)” or an asterisk with a legend", "Switch to orange"], answer: 1, why: "Changing the color doesn’t help — the cue can’t depend on color at all. Text or a symbol does."),
            spec: ["Beside each status color, write its second cue: icon, label or pattern.", "Specify links inside body text as underlined by default.", "In charts, note the direct label and the marker or pattern for each series."],
            review: ["If this screen were printed in gray, what would be lost?", "Which states differ only by hue?", "Does the chart still read without its legend colors?"],
            tradeoff: "Extra icons and labels add noise. The answer is a quieter second cue, such as weight, position or a small glyph. It is not removing the cue.",
            system: "Build the second cue into status components (badge, alert, field error) so nobody can ship color alone.",
            pitch: "About 1 in 12 men has a color vision deficiency. A color-only status is invisible to someone in almost every team that uses your product."
        ),
        "2.5.8": DeepLesson(
            meta: "5 min · interactive", demo: .taps,
            who: ["Tremors and limited dexterity", "Larger fingers", "People on the move", "Older adults"],
            takeaways: ["Targets need at least 24×24 CSS px. 44×44 — 2.5.5, Level AAA — is the comfortable goal.", "Spacing exception: a smaller target passes if a 24px circle centered on it doesn’t touch another target or another small target’s circle.", "Links inside sentences are exempt, as are targets whose size is set by the browser.", "The hit area can be bigger than the visible icon. Pad the glyph; don’t scale it."],
            failures: ["Dense toolbars of 16px icons touching each other", "A tiny × to close a modal", "Pagination and carousel dots"],
            check: ["Overlay a 24×24 square on every target in your file.", "For small targets, draw 24px circles at their centers — do any overlap?", "Annotate hit areas at handoff so developers build them."],
            quiz: Quiz(question: "A 20×20 icon button sits 20px away from the nearest other button. Does it pass?", options: ["No — it’s under 24px", "Yes — the spacing exception applies", "Only with a tooltip"], answer: 1, why: "A 24px circle centered on it doesn’t reach its neighbor, so the spacing exception applies. Still — bigger is kinder."),
            spec: ["Draw the hit area as its own annotated layer, with its size in px.", "Note the minimum spacing between neighboring targets.", "Call out anything under 24px and the exception it relies on."],
            review: ["Where is the smallest target on this screen, and who has to hit it?", "Are dense areas such as tables and toolbars leaning on the spacing exception?", "Is the hit area specified, or only the icon?"],
            tradeoff: "Density against reach. Keep the visual density if you must. Grow the invisible hit area and the spacing, not the glyphs.",
            system: "Set a minimum hit area on the base button and icon button: a 24px floor, 44px by default on touch.",
            pitch: "A missed tap is an error, a retry or an abandoned task. That is true for anyone on a moving train, not only people with tremors."
        ),
        "2.3.3": DeepLesson(
            meta: "4 min · interactive", demo: .motion,
            who: ["Vestibular disorders", "Migraine", "Attention-related disabilities", "Motion sensitivity"],
            takeaways: ["Motion triggered by interaction — parallax, zooms, big slides — can cause dizziness, nausea and migraines.", "Respect the system “Reduce motion” setting. Developers read it as prefers-reduced-motion.", "Swap travel for fades or instant changes. Keep the feedback; lose the movement.", "It’s Level AAA, but because every OS exposes the setting, it’s one of the easiest AAA wins."],
            failures: ["Scroll-driven parallax with no off switch", "Full-screen zoom transitions between pages", "Backgrounds that shift as you scroll"],
            check: ["Turn on Reduce motion on your device and walk through the prototype.", "Spec a reduced alternative for every animation at handoff.", "Ask of each animation: is it essential, or decoration?"],
            quiz: Quiz(question: "Your onboarding uses heavy parallax as people scroll. What does 2.3.3 ask for?", options: ["Remove all animation", "A way to turn that motion off", "Slow it below 3 per second"], answer: 1, why: "Most people can keep the motion — but those affected need to turn it off, for example by honoring Reduce motion."),
            spec: ["For every animation, specify a reduced version: a fade, or no transition.", "Mark which motion is essential to understanding, and why.", "Reference the system setting so developers wire up prefers-reduced-motion."],
            review: ["What does this flow look like with Reduce motion on?", "Which animation here is decoration, and which carries meaning?", "Does anything move without the person triggering it? That is 2.2.2."],
            tradeoff: "Motion is part of the brand. Reduced does not mean none: keep opacity and color changes, drop travel, scale and parallax.",
            system: "Give every motion token a reduced value, so each component gets the alternative for free.",
            pitch: "The setting already exists on every device and people already use it. Ignoring it means making some customers feel ill."
        ),
        "1.4.11": DeepLesson(
            meta: "4 min read", demo: nil,
            who: ["Low vision", "Color vision deficiency", "Aging eyes", "Screen glare"],
            takeaways: ["Anything you must see to use a control needs 3:1 against what is next to it: field borders, icons, toggles, checkboxes.", "States count. Focus rings and selected states need 3:1 too.", "In charts and diagrams, the parts needed to understand the graphic need 3:1.", "Inactive controls and purely decorative graphics are exempt."],
            failures: ["Pale gray input borders on white", "Light icon-only buttons", "A toggle whose on and off states differ by a faint tint"],
            check: ["Sample each control edge and icon against its background.", "Check every state: default, hover, focus, selected.", "In charts, check neighboring segments against each other."],
            quiz: Quiz(question: "A text field has a #CCCCCC border on white, about 1.6:1. Nothing else marks its edges. Does it pass?", options: ["Yes. Borders are decorative", "No. It needs 3:1", "No. It needs 4.5:1"], answer: 1, why: "The border is the only thing showing where the field is, so it needs 3:1. The 4.5:1 rule is for text."),
            spec: ["Note the ratio beside each border, icon and state indicator.", "Specify focus and selected states with their own colors.", "For charts, list the palette with neighboring-color ratios, or add separators."],
            review: ["Could you find every input on this screen with your eyes half closed?", "Which icons carry meaning with no label?", "Do selected and unselected look different without color?"],
            tradeoff: "Quiet, barely-there borders are fashionable and they fail. Keep the calm look with a darker hairline that reaches 3:1.",
            system: "Define border and icon tokens that reach 3:1 on every surface they are allowed on.",
            pitch: "If people cannot see where a field is, they cannot fill it in. That is a conversion problem before it is a compliance one."
        ),
        "2.4.7": DeepLesson(
            meta: "4 min read", demo: nil,
            who: ["Keyboard users", "Switch and voice control users", "Low vision", "Power users"],
            takeaways: ["Every interactive element shows a visible indicator when it has keyboard focus.", "Design it. Do not leave it to the browser default, and never remove it.", "A good target, from 2.4.13: a 2px outline, offset from the element, with 3:1 contrast.", "It has to work on every background the component sits on."],
            failures: ["The outline removed in the stylesheet", "A focus style so faint nobody notices it", "Custom components with no focus state drawn"],
            check: ["Tab through the prototype or build. Can you always tell where you are?", "Check the focus style on light, dark and image backgrounds.", "Include a focus state in every component’s state list."],
            quiz: Quiz(question: "A designer removes the focus outline because mouse users see it after clicking. What is the best response?", options: ["Agree. It is visual noise", "Keep a designed style that shows for keyboard focus", "Replace it with a color change on hover"], answer: 1, why: "Developers can show the ring only for keyboard use. Hover does nothing for people who do not use a pointer."),
            spec: ["Draw the focus state for every interactive component.", "Give the ring’s width, offset and color as values.", "Show it on each surface color the component can sit on."],
            review: ["Where is the focus state for this component?", "Does the ring survive on the darkest and lightest backgrounds?", "Does a sticky bar ever cover the focused element? That is 2.4.11."],
            tradeoff: "A strong ring can clash with a refined style. A two-tone ring, light and dark together, stays visible everywhere and can be tuned to the brand.",
            system: "One focus token, applied by every component. Nobody should design a focus ring twice.",
            pitch: "Without visible focus, a keyboard user is operating your product blindfolded."
        ),
        "1.1.1": DeepLesson(
            meta: "5 min read", demo: nil,
            who: ["Screen reader users", "Low vision", "Voice control users", "Slow connections with images off"],
            takeaways: ["A meaningful image needs a text alternative that does the same job as the image.", "Decorative images are marked so assistive tech skips them.", "Icon-only buttons need a name. Describe the action, not the picture: “Close”, not “X icon”.", "Complex images such as charts need a short alternative plus a longer description nearby."],
            failures: ["Icon buttons with no accessible name", "Alt text that says “image” or repeats the file name", "Charts with no text summary"],
            check: ["For each image, ask: if it vanished, what would be lost? Write that down.", "Mark every image as decorative or meaningful in the file.", "Name every icon-only control."],
            quiz: Quiz(question: "A magnifying-glass icon button submits a search. What is the best text alternative?", options: ["“Magnifying glass”", "“Search”", "None. It is decorative"], answer: 1, why: "Describe what the control does. The picture means nothing to someone who cannot see it."),
            spec: ["Annotate each image as decorative or meaningful.", "Write the alt text yourself for meaningful images.", "Give every icon-only control its accessible name."],
            review: ["Who wrote the alt text here: the designer, or nobody?", "Which icons have no visible label, and what are they called?", "What is the text equivalent of this chart?"],
            tradeoff: "Icon-only interfaces are compact and ambiguous for everyone. Where space allows, a visible label beats a hidden name.",
            system: "Make the accessible name a required property on icon button and image components.",
            pitch: "Alt text is content. If nobody owns it, it ships empty."
        ),
        "3.3.2": DeepLesson(
            meta: "4 min read", demo: nil,
            who: ["Cognitive and memory disabilities", "Screen reader users", "Low vision with zoom", "Anyone interrupted mid-form"],
            takeaways: ["Every input has a label that stays visible while people type.", "Placeholders are not labels. They vanish, and are often low contrast.", "Say what format you need before people get it wrong: date order, password rules.", "Mark required fields in words, or with a symbol you explain."],
            failures: ["Placeholder-only fields", "Format rules revealed only in the error", "A group of fields, such as a date, with one vague label"],
            check: ["Fill in the form, then look again. Can you still tell what each field is?", "Check that every hint appears before the input, not after an error.", "Check that required and optional differ by more than color."],
            quiz: Quiz(question: "A date field accepts only DD/MM/YYYY. Where does that instruction belong?", options: ["In the error message", "Visible with the label, before typing", "In the placeholder"], answer: 1, why: "Instructions prevent errors. A placeholder disappears at the moment it is needed."),
            spec: ["Write the label, hint and required state for every field.", "Note which hint text stays on screen.", "For grouped fields, give the group label and each part’s label."],
            review: ["Which fields lose their label once filled?", "What does someone need to know before typing here?", "Could the form ask for less?"],
            tradeoff: "Labels above fields cost vertical space. Floating labels save it, but must stay readable in size and contrast once floated.",
            system: "Make label a required property on the field component, with hint and required built in.",
            pitch: "Every unclear field is a support ticket or an abandoned form."
        ),
        "1.3.1": DeepLesson(
            meta: "5 min read", demo: nil,
            who: ["Screen reader users", "Keyboard users who jump by heading", "People using reader modes", "Voice control users"],
            takeaways: ["If it looks like a heading, a list, a table or a group, it must be one in code.", "Heading levels describe structure, not size. Do not skip a level to get a style.", "Labels are tied to their fields. Related fields are grouped under a group label.", "Your layers and annotations are where this structure gets decided."],
            failures: ["Bold text used as a heading", "Tables built from loose boxes", "Radio buttons with no group label"],
            check: ["Outline the page using only its headings. Does it make sense?", "Label each heading with its level in the file.", "Check that every table has its header cells identified."],
            quiz: Quiz(question: "A card title should be smaller than the page’s H2 style. What do you specify?", options: ["An H4, because it is smaller", "The level the structure needs, styled smaller", "Bold body text"], answer: 1, why: "Level follows structure. Style is separate, and a good system lets you pair any level with any size."),
            spec: ["Mark heading levels on the frame.", "Identify lists, tables and their header cells.", "Name each field group and page region."],
            review: ["Read me the heading outline of this page.", "Which groups exist visually but have no name?", "Is this really a table, or a layout?"],
            tradeoff: "Visual hierarchy and document hierarchy sometimes disagree. Separate level from style. Do not pick the level that looks right.",
            system: "Let heading components take level and size as separate properties.",
            pitch: "Structure is how a screen reader user skims. Without it, they have to listen to everything."
        ),
        "2.4.6": DeepLesson(
            meta: "4 min read", demo: nil,
            who: ["Screen reader users", "Cognitive disabilities", "People who skim", "Screen magnifier users"],
            takeaways: ["Headings and labels describe what follows. People should know a section from its heading alone.", "Put the distinguishing words first: “Billing address”, not “Address for billing”.", "Avoid vague headings where clarity is needed: “Overview”, “More”, “Details”.", "This one is about quality. Whether headings exist in code is 1.3.1."],
            failures: ["Several sections all headed “Details”", "Buttons all labelled “Submit” for different actions", "Clever headings that hide what the section contains"],
            check: ["Read only the headings. Could you find what you need?", "Read each label out of context. Is it still clear?", "Look for identical labels that mean different things."],
            quiz: Quiz(question: "Two sections of a settings page are both headed “Options”. What does 2.4.6 ask for?", options: ["Different heading levels", "Headings that describe each section", "Removing one of the headings"], answer: 1, why: "A heading has to describe its topic. The same heading on different content describes neither."),
            spec: ["Write final heading and label copy in the design, not placeholder text.", "Flag labels that need a content review.", "Where a visible label is shortened, note the full name."],
            review: ["If I read only the headings, would I know what this page does?", "Which labels only make sense next to their neighbors?", "Who wrote this copy, and has anyone tested it?"],
            tradeoff: "Brand voice wants personality. Navigation wants clarity. Put the voice in body copy and keep headings and labels literal.",
            system: "Publish naming guidance with the components: verbs for buttons, nouns for headings.",
            pitch: "Clear headings are how everyone skims. This fix helps every single user."
        ),
        "1.4.4": DeepLesson(
            meta: "4 min read", demo: nil,
            who: ["Low vision", "Older adults", "People on small screens", "Anyone without their glasses"],
            takeaways: ["Text can be enlarged to 200% without losing content or function.", "Design for growth: containers expand, text wraps, nothing is clipped.", "Avoid fixed heights on anything that holds text.", "On phones, respect the system text size setting."],
            failures: ["Text cut off or overlapping when enlarged", "Fixed-height buttons that clip two-line labels", "Layouts that only work with one line of text"],
            check: ["Zoom the browser to 200% and use the page.", "Set your phone to its largest text size and open the app.", "Stress-test components with double-length text."],
            quiz: Quiz(question: "At 200% text size a tab label is cut off with an ellipsis, and there is no other way to read it. Does it pass?", options: ["Yes. Truncation is a standard pattern", "No. Content is lost", "Yes, at Level AA"], answer: 1, why: "If the full label cannot be read, content is lost. Let it wrap, or let the tabs scroll."),
            spec: ["Show how each component grows: wrap, expand or scroll.", "Mark containers as hugging their content, not fixed height.", "Include a large-text version of key screens."],
            review: ["What does this screen look like at the largest text size?", "Which elements have fixed heights?", "Where will long translations break this layout?"],
            tradeoff: "Tight, pixel-perfect layouts break first. Flexible layouts look a little less controlled and survive real use, including translation.",
            system: "Build components with auto layout and test each one at 200% before release.",
            pitch: "Many people run their phone at a larger text size. A layout that breaks under it breaks for them every day."
        ),
    ]

    static let paths: [LearningPath] = [
        LearningPath(id: "first10", name: "The first ten", desc: "The criteria decided in your design file. Start here.", list: ["1.4.3", "1.4.1", "1.4.11", "2.5.8", "2.4.7", "1.1.1", "3.3.2", "1.3.1", "2.4.6", "1.4.4"]),
        LearningPath(id: "forms", name: "Forms", desc: "Labels, errors, sign-in and not asking twice.", list: ["3.3.2", "3.3.1", "3.3.3", "1.3.5", "3.3.7", "3.3.8", "3.3.4", "1.4.11"]),
        LearningPath(id: "mobile", name: "Mobile and touch", desc: "Targets, gestures, dragging and orientation.", list: ["2.5.8", "2.5.1", "2.5.7", "1.3.4", "2.5.4", "1.4.10", "2.5.2"]),
        LearningPath(id: "motion", name: "Motion and time", desc: "Animation, flashing, auto-play and time limits.", list: ["2.3.3", "2.2.2", "2.3.1", "2.2.1", "1.4.13"]),
        LearningPath(id: "review", name: "Reviewing work", desc: "What to look for in someone else’s flow.", list: ["1.3.1", "1.3.2", "2.4.3", "2.4.6", "2.1.1", "3.2.3", "3.3.4", "4.1.3"]),
        LearningPath(id: "systems", name: "Design systems", desc: "Rules to build into tokens and components once.", list: ["1.4.3", "1.4.11", "2.4.7", "2.4.11", "2.4.13", "3.2.4", "2.5.3", "4.1.2", "1.4.12"]),
    ]

    static let scenarios: [Scenario] = [
        Scenario(text: "Form errors are shown only by turning the field’s border red.", options: ["1.4.1", "1.4.3", "3.3.2"], answer: 0, why: "Color is the only cue. Add an error message and an icon — which also satisfies 3.3.1."),
        Scenario(text: "Caption text is #AAAAAA on a white card.", options: ["2.4.7", "1.4.3", "1.1.1"], answer: 1, why: "#AAAAAA on white is about 2.3:1. Text at that size needs 4.5:1."),
        Scenario(text: "A 16×16 close icon sits right against a 16×16 share icon.", options: ["1.4.10", "2.1.1", "2.5.8"], answer: 2, why: "Both are under 24px and too close together for the spacing exception."),
        Scenario(text: "A sign-up form’s only labels are placeholders that vanish as you type.", options: ["3.3.2", "1.3.5", "2.4.2"], answer: 0, why: "Once typing starts, nothing tells people what the field is for. Keep a visible label."),
        Scenario(text: "The focus outline was removed because it “looked messy”.", options: ["2.4.3", "2.4.7", "1.4.11"], answer: 1, why: "Keyboard users lose their place entirely. Design a focus style that fits the brand instead."),
        Scenario(text: "A promo banner image contains the sale price, with no text alternative.", options: ["1.4.5", "1.1.1", "1.3.1"], answer: 1, why: "Meaningful images need a text alternative. Baking text into the image also runs into 1.4.5."),
        Scenario(text: "Pages zoom and slide dramatically as you scroll, and there’s no way to turn it off.", options: ["2.3.1", "2.2.2", "2.3.3"], answer: 2, why: "Interaction-triggered motion must be possible to disable. 2.3.1 is about flashing, not movement."),
        Scenario(text: "Logging in means solving a puzzle, and password managers can’t paste into the field.", options: ["3.3.8", "2.2.1", "3.3.7"], answer: 0, why: "New in WCAG 2.2: no cognitive tests to log in unless there’s an alternative such as paste, passkeys or a magic link."),
    ]

    static let roles: [Role] = [
        Role(id: "Junior", desc: "I design screens and components from a brief."),
        Role(id: "Mid", desc: "I own features end to end and hand them to developers."),
        Role(id: "Senior", desc: "I shape whole flows and review other designers’ work."),
        Role(id: "Lead", desc: "I set standards, systems and priorities for a team."),
    ]

    static let levelBlurbs: [String: String] = [
        "New": "You are building the foundations. Lessons start with what each rule is and who it helps.",
        "Working": "You know the common rules. Lessons start with how to apply and specify them.",
        "Fluent": "You can cite criteria. Lessons start with trade-offs, reviews and systems.",
    ]

    static let reviewIntervals: [Int] = [1, 3, 7, 21, 60]

    static let diagnostic: [DiagQuestion] = [
        DiagQuestion(question: "Pale gray text on a white card is hard to read. Which principle does that touch?", options: ["Perceivable", "Operable", "Robust"], answer: 0),
        DiagQuestion(question: "Which WCAG level do most laws and policies point to?", options: ["Level A", "Level AA", "Level AAA"], answer: 1),
        DiagQuestion(question: "What is the minimum contrast for 16px regular body text?", options: ["3:1", "4.5:1", "7:1"], answer: 1),
        DiagQuestion(question: "A text field is shown only by its border. What contrast does that border need against the background?", options: ["No requirement", "3:1", "4.5:1"], answer: 1),
        DiagQuestion(question: "While tabbing, a sticky footer completely covers the focused button. Which criterion fails?", options: ["2.4.7 Focus Visible", "2.4.11 Focus Not Obscured", "2.4.3 Focus Order"], answer: 1),
        DiagQuestion(question: "A price slider can only be moved by dragging. What does WCAG 2.2 AA ask for?", options: ["A way to do it with single taps or clicks", "A larger slider thumb", "Nothing. Sliders are exempt"], answer: 0),
    ]

    static let roleTasks: [String: RoleTask] = [
        "Junior": RoleTask(name: "Fix the screen", desc: "One screen, one problem. Pick the fix you would make in the file.", questions: [
            RoleQuestion(text: "A primary button has white text on #6FB1FF. The ratio is about 2.2:1.", options: ["Darken the blue until white text reaches 4.5:1", "Make the label bold", "Add a soft shadow behind the text"], answer: 0, criterion: "1.4.3", why: "Bold 16px still is not large text, and a shadow does not change the ratio. Fix the color pair."),
            RoleQuestion(text: "A toolbar has 16px icons sitting 4px apart.", options: ["Add tooltips to each icon", "Keep the glyphs, pad each hit area to 24px or more", "Raise the icon contrast"], answer: 1, criterion: "2.5.8", why: "The glyph can stay small. The area that responds to a tap is what needs room."),
            RoleQuestion(text: "An invalid field is shown only by a red border.", options: ["Use a darker red", "Shake the field", "Add an icon and a message that says what is wrong"], answer: 2, criterion: "1.4.1", why: "The cue cannot depend on color. Words also tell people how to fix it."),
        ]),
        "Mid": RoleTask(name: "Annotate the handoff", desc: "The design is done. Decide what the developer needs written down.", questions: [
            RoleQuestion(text: "A card has a photo, a title and a “Read more” link. What do you note for the photo?", options: ["Its export resolution", "Whether it is decorative or meaningful, and its text alternative", "Nothing. Alt text is a developer decision"], answer: 1, criterion: "1.1.1", why: "Only the person who chose the image knows what it is there to say."),
            RoleQuestion(text: "A button opens a modal. Which note prevents the most common bug?", options: ["Focus moves into the modal, stays there, and returns to the button on close", "The overlay opacity", "The easing curve"], answer: 0, criterion: "2.4.3", why: "Without it, keyboard focus stays on the page behind the modal."),
            RoleQuestion(text: "Your layout reads in a different order than a developer would guess from the columns.", options: ["Note the column widths", "Note the layer order", "Number the reading and focus order on the frame"], answer: 2, criterion: "1.3.2", why: "Screen readers follow code order. If you do not specify it, it is guessed."),
        ]),
        "Senior": RoleTask(name: "Critique the flow", desc: "You are reviewing a teammate’s work. Choose what matters most.", questions: [
            RoleQuestion(text: "A checkout review finds three issues and there is one sprint. Which goes first?", options: ["Helper text at 4.2:1", "The Pay button cannot be reached by keyboard", "The promo carousel has no pause control"], answer: 1, criterion: "2.1.1", why: "A total block on the critical path outranks friction. Some people cannot pay at all."),
            RoleQuestion(text: "The flow asks for the address at shipping, then again at billing.", options: ["Fine, as long as both are labelled", "Move billing first", "Offer “same as shipping” or pre-fill it"], answer: 2, criterion: "3.3.7", why: "New in 2.2: do not make people re-enter what they already gave in the same process."),
            RoleQuestion(text: "A designer says the 20-minute session timeout is a security requirement.", options: ["Ask for a warning before it expires, with a way to extend", "Ask to remove the timeout", "Ask for a shorter timeout so it is noticed"], answer: 0, criterion: "2.2.1", why: "The limit can stay. People need to be warned and able to extend it."),
        ]),
        "Lead": RoleTask(name: "Make the call", desc: "No single screen to fix. Decide the rule, the priority, the argument.", questions: [
            RoleQuestion(text: "Brand wants white text on the primary yellow, #FFB400. It measures about 1.8:1.", options: ["Grant a brand exception", "Keep the yellow, pair it with dark text, and ship the pair as a token", "Allow it for text over 24px"], answer: 1, criterion: "1.4.3", why: "1.8:1 fails even for large text. The hue can stay. The pairing changes, once, for everyone."),
            RoleQuestion(text: "Where does a contrast rule do the most good?", options: ["In a pre-launch audit", "In a guidelines document", "In tokens and components every team inherits"], answer: 2, criterion: "1.4.11", why: "Audits find problems after they are built. Systems stop them being built."),
            RoleQuestion(text: "A stakeholder says accessibility can wait until after launch.", options: ["Show the cost of retrofitting and scope the AA essentials into this release", "Say it is the right thing to do", "Agree and add it to the backlog"], answer: 0, criterion: "2.4.7", why: "Values rarely move a roadmap. Cost, risk and a small, concrete scope do."),
        ]),
    ]

    static let laws: [Law] = [
        Law(region: "EUROPEAN UNION", law: "European Accessibility Act", note: "Covers many consumer products and services. Its technical standard, EN 301 549, builds on WCAG Level AA."),
        Law(region: "UNITED STATES", law: "ADA and Section 508", note: "Section 508 covers federal agencies. ADA rules for state and local government name WCAG Level AA."),
        Law(region: "UNITED KINGDOM", law: "Public Sector Bodies Accessibility Regulations", note: "Public sector websites and apps are expected to meet WCAG Level AA."),
        Law(region: "CANADA", law: "Accessible Canada Act, AODA in Ontario", note: "Federal and provincial rules that reference WCAG."),
        Law(region: "AUSTRALIA", law: "Disability Discrimination Act", note: "Official guidance uses WCAG as the reference."),
    ]
}
