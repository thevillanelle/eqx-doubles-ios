import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var showSplash = true
    @AppStorage("isDark") private var isDark = true

    var body: some View {
        ZStack {
            TabView {
                SearchView(viewModel: viewModel)
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }

                ResultsView(viewModel: viewModel)
                    .tabItem { Label("Results", systemImage: "list.bullet") }
                    .badge(viewModel.results.isEmpty ? 0 : viewModel.results.count)

                ClubsView()
                    .tabItem { Label("Clubs", systemImage: "building.2") }
            }
            .tint(Color(red: 0.78, green: 0.95, blue: 0.23))
            .preferredColorScheme(isDark ? .dark : .light)

            if showSplash {
                SplashView { showSplash = false }
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
    }
}
