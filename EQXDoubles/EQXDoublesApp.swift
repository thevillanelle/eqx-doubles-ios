//
// EQXDoublesApp.swift — App Entry Point
// ======================================
//
// In Swift, `@main` marks the entry point of the program.
// When you press ▶ Run in Xcode, the compiler looks for a type annotated
// with `@main` and calls its `main()` function (which SwiftUI provides).
//
// Compare to Python: `if __name__ == '__main__': app.run()`
// Or to C: `int main() { ... }`
//
// In Swift, the App protocol requires a `body` property (just like View).
// `body` returns a `Scene` — a top-level unit of your app's UI.
// `WindowGroup` is the standard scene for a window-based app.
//

import SwiftUI

// `@main` — "start here"
@main
struct EQXDoublesApp: App {
    // `var body: some Scene` — required by the App protocol.
    // `Scene` is like `View` but at the app level.
    var body: some Scene {
        WindowGroup {
            // ContentView is the root of our view hierarchy.
            // Everything else flows from here.
            ContentView()
                // Force dark mode — our design is dark-first
                .preferredColorScheme(.dark)
        }
    }
}
