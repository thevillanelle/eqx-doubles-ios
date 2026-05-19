//
// ContentView.swift — EQX Doubles
// ================================
// The root view of the app. Uses a TabView to switch between Search and Results.
//
// `@StateObject`: creates and OWNS the view model.
// Unlike @ObservedObject (which watches an existing object),
// @StateObject creates the object and keeps it alive as long as this view exists.
// This is the ONE place where the SearchViewModel is created.
//

import SwiftUI

struct ContentView: View {

    // `@StateObject` creates the object once and holds a strong reference.
    // The $ prefix gives us the "projected value" (a binding / publisher).
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        // `TabView` = the bottom tab bar (like UITabBarController)
        TabView {
            // Tab 1: Search
            SearchView(viewModel: viewModel)
                // `.tabItem` describes how this tab looks in the tab bar
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            // Tab 2: Results
            ResultsView(viewModel: viewModel)
                .tabItem {
                    Label("Results", systemImage: "list.bullet")
                }
                // `.badge` shows a count on the tab icon
                .badge(viewModel.results.isEmpty ? 0 : viewModel.results.count)
        }
        // `.tint` sets the accent color — this is the lime green for the tab bar and toggles
        .tint(Color(red: 0.78, green: 0.95, blue: 0.23))
    }
}
