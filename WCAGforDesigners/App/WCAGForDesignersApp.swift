import SwiftUI

@main
struct WCAGForDesignersApp: App {
    @State var store = AppStore()

    init() { Fonts.register() }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
    }
}
