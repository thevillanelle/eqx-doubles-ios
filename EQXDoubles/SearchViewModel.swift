// =============================================================================
// SearchViewModel.swift
// EQX Doubles — iOS App
// =============================================================================
//
// WHAT IS A VIEWMODEL?
// In SwiftUI, we separate:
//   • The VIEW  — pure UI description (what it looks like)
//   • The MODEL — pure data (structs with no logic)
//   • The VIEWMODEL — the glue between them (logic, state, networking)
//
// This pattern is called MVVM (Model-View-ViewModel).
//
// SearchViewModel:
//   • Holds the current search parameters (what the user has set)
//   • Holds the results array (what came back from the API)
//   • Holds loading/error state (is the spinner showing? is there an error?)
//   • Exposes a search() method that the View calls when the user taps search
//
// WHAT IS @ObservableObject?
// ObservableObject is a protocol that turns a class into something SwiftUI can
// "watch." When any @Published property changes, SwiftUI automatically
// re-renders any View that's observing this object.
//
// Think of it like a spreadsheet: when a cell changes value, all the formulas
// that depend on it automatically recalculate. @Published properties are the
// cells; @ObservedObject/StateObject views are the formulas.
//
// WHAT IS @Published?
// @Published is a property wrapper that tells SwiftUI "when this value changes,
// notify all observers." It's what makes the UI stay in sync with the data.
//
// The flow looks like this:
//   1. User taps "Find Doubles" button in SearchView
//   2. SearchView calls viewModel.search()
//   3. search() sets isLoading = true → spinner appears
//   4. search() awaits the network call
//   5. Network call finishes → results = [...] → isLoading = false
//   6. SwiftUI sees @Published properties changed → re-renders ResultsView
//   7. ResultsView shows the new results
//
// WHAT IS @MainActor?
// UI updates MUST happen on the main thread. @MainActor is Swift's way of
// guaranteeing that all code in this class runs on the main thread.
// Without it, updating @Published properties from a background thread
// would cause crashes or visual glitches.
//
// In older Swift, you'd manually call:
//   DispatchQueue.main.async { self.results = results }
// @MainActor does this automatically for every method in the class.
//
// =============================================================================

import Foundation

// MARK: - SearchViewModel

/// Manages the search state and orchestrates the API call.
///
/// @MainActor — all property updates happen on the main thread (required for UI)
/// ObservableObject — SwiftUI can observe @Published properties for changes
@MainActor
class SearchViewModel: ObservableObject {

    // MARK: - @Published Properties
    //
    // WHAT IS A PROPERTY WRAPPER?
    // @Published is a "property wrapper" — it wraps a value with extra behavior.
    // Under the hood, @Published creates a publisher (from Combine framework)
    // that fires a notification whenever the value changes.
    //
    // SwiftUI subscribes to these publishers automatically when you use
    // @ObservedObject or @StateObject in a View.

    /// The current search parameters. Every form control in SearchView modifies
    /// a field of this struct. Because it's @Published, any change immediately
    /// triggers a UI update (e.g., disabling the search button if no clubs are selected).
    @Published var params = SearchParams()

    /// The array of results from the last successful search.
    /// Empty array = either no search has run yet, or the search returned nothing.
    @Published var results: [DoubleResult] = []

    /// True while the network request is in flight.
    /// SearchView uses this to show an activity spinner and disable the button.
    @Published var isLoading = false

    /// Non-nil if the most recent search threw an error.
    /// The View displays this string in an alert or inline error message.
    @Published var error: String? = nil

    /// True once at least one search has completed (success or empty).
    /// Used to distinguish "initial state (no search yet)" from "search
    /// returned zero results."
    @Published var hasSearched = false

    // MARK: - Search Action

    /// Kicks off a search using the current `params`.
    ///
    /// WHAT IS `async` ON A METHOD?
    /// Adding `async` to a function means it can use `await` internally.
    /// It also means callers MUST use `await` when calling it:
    ///   Task { await viewModel.search() }
    ///
    /// WHY `Task { ... }`?
    /// SwiftUI button actions are synchronous (not async). To call an async
    /// function from a button, you wrap it in Task { ... }. A Task is a
    /// unit of concurrent work — it starts immediately and runs on the
    /// appropriate executor (here: main actor).
    ///
    /// WHAT IS A `do/catch` BLOCK?
    /// A do/catch block handles errors from `try` expressions:
    ///
    ///   do {
    ///       let result = try somethingThatMightFail()
    ///       // success path
    ///   } catch {
    ///       // `error` is automatically bound to the thrown error
    ///       print(error)
    ///   }
    ///
    /// If `somethingThatMightFail()` throws, execution jumps to the catch block.
    /// The variable `error` is automatically available in the catch block.
    func search() async {
        // Guard: require at least one club to be selected.
        // `guard` is like an early-return `if not`. If the condition is false,
        // run the else block (which must exit the function).
        guard !params.selectedClubIds.isEmpty else {
            error = "Please select at least one club location."
            return
        }

        // Show the loading spinner and clear any previous error
        isLoading = true
        error = nil

        do {
            // `try await` = "call this async throwing function and wait for it"
            // If it throws, jump to the `catch` block below.
            // If it succeeds, assign the result to `results`.
            let fetchedResults = try await SupabaseService.shared.findDoubles(params: params)

            // Assign results on the main thread (guaranteed by @MainActor)
            results = fetchedResults
            hasSearched = true

        } catch {
            // `error` here is the Swift Error that was thrown.
            // `localizedDescription` gives a human-readable string.
            self.error = error.localizedDescription
            // Don't clear old results — let the user see what was there before
        }

        // Always run this, whether success or failure
        isLoading = false
    }

    // MARK: - Convenience Helpers

    /// A human-readable summary of the search results count.
    var resultsSummary: String {
        if isLoading { return "Searching..." }
        if !hasSearched { return "Configure your search above" }
        switch results.count {
        case 0:  return "No doubles found"
        case 1:  return "1 double found"
        default: return "\(results.count) doubles found"
        }
    }

    /// True when the search button should be enabled.
    var canSearch: Bool {
        !isLoading && !params.selectedClubIds.isEmpty
    }

    /// Resets the search state without clearing the params (keeps user's choices).
    func clearResults() {
        results = []
        hasSearched = false
        error = nil
    }
}
