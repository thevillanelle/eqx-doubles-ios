//
// ResultsView.swift — EQX Doubles
// ================================
// Displays the list of class pairs returned from Supabase.
// This is a "presentation" view — it receives data, it doesn't fetch it.
//

import SwiftUI

struct ResultsView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        // `Group` is a transparent container — useful for conditional views
        Group {
            if viewModel.isLoading {
                // ProgressView with a label, centered on screen
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Querying database…")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if viewModel.results.isEmpty && viewModel.hasSearched {
                // Empty state — shown when search returned zero results
                VStack(spacing: 12) {
                    Text("◎")
                        .font(.system(size: 48))
                        .opacity(0.25)
                    Text("No doubles found")
                        .font(.caption)
                        .fontWeight(.bold)
                        .kerning(3)
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                    Text("Try widening the time window, selecting\nmore locations, or increasing the max gap.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if !viewModel.results.isEmpty {
                // List of results — `List` is SwiftUI's scrolling list container
                // (like UITableView, but declarative)
                List(viewModel.results) { result in
                    ResultCard(result: result)
                        // `.listRowInsets` removes the default padding
                        .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        // `.listRowBackground` sets the card background color
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)

            } else {
                // Initial state — no search yet
                VStack(spacing: 12) {
                    Text("◎")
                        .font(.system(size: 48))
                        .opacity(0.25)
                    Text("Run a search first")
                        .font(.caption)
                        .fontWeight(.bold)
                        .kerning(3)
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(viewModel.hasSearched ? "\(viewModel.results.count) Pairs" : "Results")

    }
}
