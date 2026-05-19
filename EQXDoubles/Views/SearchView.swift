//
// SearchView.swift — EQX Doubles (Swift/SwiftUI iOS App)
// ======================================================
//
// SwiftUI works by describing your UI as a VALUE tree, not a DOM tree.
// Each `View` is a lightweight Swift struct (not a class!).
// When @State or @Published values change, SwiftUI automatically re-renders
// only the parts of the screen that depend on those values.
//
// In HTML/CSS you'd write:  <div class="form-section">...</div>
// In SwiftUI you write:     VStack { ... }  or  Form { Section { ... } }
//

import SwiftUI

// ─── SearchView ───────────────────────────────────────────────────────────────
// `struct` keyword: Swift structs are VALUE types (copies, not references).
// SwiftUI views are almost always structs — they're cheap to create and
// SwiftUI recreates them constantly. That's fine! They're just descriptions.
//
// `: View` means "SearchView conforms to the View protocol".
// A protocol in Swift is like an interface — it says "this type MUST have
// a `body` property that returns some kind of View".

struct SearchView: View {

    // @ObservedObject: "watch this object for changes".
    // When the viewModel publishes a change, this view re-renders.
    // The `var` keyword declares a mutable variable. `let` would be constant.
    @ObservedObject var viewModel: SearchViewModel

    // @State: "this view owns this small piece of local state".
    // The `private` keyword means only this struct can access it.
    // The underscore prefix `_showResults` is a convention for private state.
    @State private var showResults = false

    // `var body: some View` — this is REQUIRED by the View protocol.
    // `some View` means "returns some specific View type, I'm not telling you which".
    // SwiftUI infers the actual type at compile time.
    var body: some View {
        // NavigationStack: like a UINavigationController — gives you the top nav bar
        // and the ability to push/pop views.
        NavigationStack {
            // Form: a scrollable, grouped list layout — perfect for settings/search forms.
            Form {
                locationsSection
                classPairSection
                dateSection
                timeWindowSection
                gapSection
                orderSection
                searchButtonSection
            }
            .navigationTitle("EQX Doubles")
            // .navigationBarTitleDisplayMode: how big the title is
            .navigationBarTitleDisplayMode(.large)
            // `.toolbar` adds items to the navigation bar
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // `NavigationLink` pushes a new view when tapped
                    NavigationLink("Results") {
                        ResultsView(viewModel: viewModel)
                    }
                    .disabled(viewModel.results.isEmpty)
                }
            }
        }
    }

    // ── LOCATIONS SECTION ──────────────────────────────────────────────────────
    // `@ViewBuilder` lets you return multiple views from a computed property.
    // This is just a way to split up the `body` into smaller pieces — Swift
    // requires all of this to be one big expression otherwise.
    @ViewBuilder
    var locationsSection: some View {
        Section {
            // `ForEach` iterates over a collection and creates a View for each item.
            // In SwiftUI it's NOT a loop statement — it returns a View.
            // `Club.neighborhoods` is a computed property that groups clubs by area.
            ForEach(Club.neighborhoods, id: \.key) { area, neighborhoods in
                // `DisclosureGroup`: an expandable/collapsible section (like <details> in HTML)
                DisclosureGroup(area) {
                    ForEach(neighborhoods, id: \.key) { nbhd, clubs in
                        Section(header: Text(nbhd).font(.caption2).textCase(.uppercase)) {
                            ForEach(clubs) { club in
                                // `Toggle`: a labeled switch / checkbox
                                Toggle(club.name, isOn: Binding(
                                    // `Binding` creates a two-way connection to some state.
                                    // `get`: how to READ the value
                                    get:  { viewModel.params.selectedClubIds.contains(club.id) },
                                    // `set`: how to WRITE the value when the toggle is flipped
                                    set:  { on in
                                        if on { viewModel.params.selectedClubIds.insert(club.id) }
                                        else  { viewModel.params.selectedClubIds.remove(club.id) }
                                    }
                                ))
                                .toggleStyle(.automatic)
                            }
                        }
                    }
                }
            }
        } header: {
            // `HStack` = horizontal stack (like `display:flex; flex-direction:row`)
            HStack {
                Text("Locations")
                Spacer() // fills remaining space — pushes the count to the right
                Text("\(viewModel.params.selectedClubIds.count) selected")
                    .foregroundColor(.green) // lime-ish — real lime green is set in assets
            }
        }
    }

    // ── CLASS PAIR SECTION ─────────────────────────────────────────────────────
    @ViewBuilder
    var classPairSection: some View {
        Section("Class Pair") {
            // `Picker` = a dropdown / segmented control / wheel selector
            // The `selection:` binding two-way connects to `viewModel.params.cat1`
            Picker("① First Class", selection: $viewModel.params.cat1) {
                // `ForEach` over all categories; `$0` is the shorthand for the element
                ForEach(Category.all) { cat in
                    Text(cat.label).tag(cat.id)
                }
            }
            Picker("② Second Class", selection: $viewModel.params.cat2) {
                ForEach(Category.all) { cat in
                    Text(cat.label).tag(cat.id)
                }
            }
        }
    }

    // ── DATE SECTION ──────────────────────────────────────────────────────────
    @ViewBuilder
    var dateSection: some View {
        Section("Date") {
            // `DatePicker` = a native date selector
            // `.datePickerStyle(.compact)` = shows as a single inline row
            DatePicker("Search Date",
                       selection: $viewModel.params.date,
                       displayedComponents: .date)
            .datePickerStyle(.compact)
        }
    }

    // ── TIME WINDOW SECTION ────────────────────────────────────────────────────
    @ViewBuilder
    var timeWindowSection: some View {
        Section("Time Window") {
            // Segmented picker for time-of-day presets
            Picker("Time of Day", selection: Binding(
                get: {
                    // Map winStart/winEnd back to a preset label
                    if viewModel.params.winStart == 300  && viewModel.params.winEnd == 1380 { return "Any Time" }
                    if viewModel.params.winStart == 300  && viewModel.params.winEnd == 540  { return "Early AM" }
                    if viewModel.params.winStart == 540  && viewModel.params.winEnd == 720  { return "Late AM"  }
                    if viewModel.params.winStart == 720  && viewModel.params.winEnd == 900  { return "Afternoon"}
                    if viewModel.params.winStart == 1080 && viewModel.params.winEnd == 1260 { return "Evening"  }
                    return "Custom"
                },
                set: { preset in
                    switch preset {
                    case "Any Time":  viewModel.params.winStart = 300;  viewModel.params.winEnd = 1380
                    case "Early AM":  viewModel.params.winStart = 300;  viewModel.params.winEnd = 540
                    case "Late AM":   viewModel.params.winStart = 540;  viewModel.params.winEnd = 720
                    case "Afternoon": viewModel.params.winStart = 720;  viewModel.params.winEnd = 900
                    case "Evening":   viewModel.params.winStart = 1080; viewModel.params.winEnd = 1260
                    default: break
                    }
                }
            )) {
                Text("Any Time").tag("Any Time")
                Text("Early AM").tag("Early AM")
                Text("Late AM").tag("Late AM")
                Text("Afternoon").tag("Afternoon")
                Text("Evening").tag("Evening")
            }
            .pickerStyle(.menu)
        }
    }

    // ── GAP SECTION ───────────────────────────────────────────────────────────
    @ViewBuilder
    var gapSection: some View {
        Section("Max Gap Between Classes") {
            // `.segmented` makes it look like a tab bar selector
            Picker("Max Gap", selection: $viewModel.params.maxGap) {
                Text("≤15m").tag(15)
                Text("≤30m").tag(30)
                Text("≤45m").tag(45)
                Text("≤60m").tag(60)
            }
            .pickerStyle(.segmented)
        }
    }

    // ── ORDER SECTION ─────────────────────────────────────────────────────────
    @ViewBuilder
    var orderSection: some View {
        Section("Pair Order") {
            Picker("Order", selection: $viewModel.params.pairOrder) {
                Text("Either Order").tag("either")
                Text("① First → ②").tag("1first")
                Text("② First → ①").tag("2first")
            }
            .pickerStyle(.segmented)
        }
    }

    // ── SEARCH BUTTON ─────────────────────────────────────────────────────────
    @ViewBuilder
    var searchButtonSection: some View {
        Section {
            // `Button` with an async action — we use `Task` to run async code from a sync context.
            // In Swift, UI code must run on the "main thread". `@MainActor` on the ViewModel
            // ensures updates happen there automatically.
            Button {
                Task {
                    await viewModel.search()
                    if !viewModel.results.isEmpty { showResults = true }
                }
            } label: {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        // `ProgressView` = a spinning loading indicator
                        ProgressView()
                            .tint(.black)
                    } else {
                        Text("Find Doubles →")
                            .fontWeight(.bold)
                            .kerning(2)
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color(red: 0.78, green: 0.95, blue: 0.23)) // lime #c8f23a
            .foregroundColor(.black)
            .disabled(viewModel.isLoading || viewModel.params.selectedClubIds.isEmpty)

            // Show error if one occurred
            if let error = viewModel.error {
                Text("⚠ \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        // `navigationDestination`: when `showResults` becomes true, push ResultsView
        .navigationDestination(isPresented: $showResults) {
            ResultsView(viewModel: viewModel)
        }
    }
}
