import SwiftUI

struct SearchView: View {

    @ObservedObject var viewModel: SearchViewModel
    @State private var showResults = false

    var body: some View {
        NavigationStack {
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
            .toolbar {
                // .primaryAction works on iOS, macOS, and all Apple platforms.
                // .navigationBarTrailing is iOS-only and was causing the macOS error.
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink("Results") {
                        ResultsView(viewModel: viewModel)
                    }
                    .disabled(viewModel.results.isEmpty)
                }
            }
        }
    }

    // ── LOCATIONS ─────────────────────────────────────────────────────────────
    // Club.neighborhoods returns [String] — a flat sorted list of neighborhood names.
    // We iterate that, then filter Club.allClubs for each neighborhood.
    @ViewBuilder
    var locationsSection: some View {
        Section {
            ForEach(Club.neighborhoods, id: \.self) { neighborhood in
                DisclosureGroup(neighborhood) {
                    ForEach(Club.allClubs.filter { $0.neighborhood == neighborhood }) { club in
                        Toggle(club.name, isOn: Binding(
                            get: { viewModel.params.selectedClubIds.contains(club.id) },
                            set: { on in
                                if on { viewModel.params.selectedClubIds.insert(club.id) }
                                else  { viewModel.params.selectedClubIds.remove(club.id) }
                            }
                        ))
                    }
                }
            }
        } header: {
            HStack {
                Text("Locations")
                Spacer()
                Text("\(viewModel.params.selectedClubIds.count) selected")
                    .foregroundColor(.green)
            }
        }
    }

    // ── CLASS PAIR ─────────────────────────────────────────────────────────────
    // Category.allCategories is the correct property name (not Category.all).
    @ViewBuilder
    var classPairSection: some View {
        Section("Class Pair") {
            Picker("\u2460 First Class", selection: $viewModel.params.cat1) {
                ForEach(Category.allCategories) { cat in
                    Text(cat.label).tag(cat.id)
                }
            }
            Picker("\u2461 Second Class", selection: $viewModel.params.cat2) {
                ForEach(Category.allCategories) { cat in
                    Text(cat.label).tag(cat.id)
                }
            }
        }
    }

    // ── DATE ───────────────────────────────────────────────────────────────────
    @ViewBuilder
    var dateSection: some View {
        Section("Date") {
            DatePicker("Search Date",
                       selection: $viewModel.params.date,
                       displayedComponents: .date)
            .datePickerStyle(.compact)
        }
    }

    // ── TIME WINDOW ────────────────────────────────────────────────────────────
    @ViewBuilder
    var timeWindowSection: some View {
        Section("Time Window") {
            Picker("Time of Day", selection: Binding(
                get: {
                    if viewModel.params.winStart == 300  && viewModel.params.winEnd == 1380 { return "Any Time" }
                    if viewModel.params.winStart == 300  && viewModel.params.winEnd == 540  { return "Early AM" }
                    if viewModel.params.winStart == 540  && viewModel.params.winEnd == 720  { return "Late AM"  }
                    if viewModel.params.winStart == 720  && viewModel.params.winEnd == 900  { return "Afternoon"}
                    if viewModel.params.winStart == 1080 && viewModel.params.winEnd == 1260 { return "Evening"  }
                    return "Any Time"
                },
                set: { preset in
                    switch preset {
                    case "Any Time":  viewModel.params.winStart = 300;  viewModel.params.winEnd = 1380
                    case "Early AM":  viewModel.params.winStart = 300;  viewModel.params.winEnd = 540
                    case "Late AM":   viewModel.params.winStart = 540;  viewModel.params.winEnd = 720
                    case "Afternoon": viewModel.params.winStart = 720;  viewModel.params.winEnd = 900
                    case "Evening":   viewModel.params.winStart = 1080; viewModel.params.winEnd = 1260
                    default:          viewModel.params.winStart = 300;  viewModel.params.winEnd = 1380
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

    // ── GAP ────────────────────────────────────────────────────────────────────
    @ViewBuilder
    var gapSection: some View {
        Section("Max Gap Between Classes") {
            Picker("Max Gap", selection: $viewModel.params.maxGap) {
                Text("\u226415m").tag(15)
                Text("\u226430m").tag(30)
                Text("\u226445m").tag(45)
                Text("\u226460m").tag(60)
            }
            .pickerStyle(.segmented)
        }
    }

    // ── ORDER ──────────────────────────────────────────────────────────────────
    @ViewBuilder
    var orderSection: some View {
        Section("Pair Order") {
            Picker("Order", selection: $viewModel.params.pairOrder) {
                Text("Either Order").tag("either")
                Text("\u2460 First \u2192 \u2461").tag("1first")
                Text("\u2461 First \u2192 \u2460").tag("2first")
            }
            .pickerStyle(.segmented)
        }
    }

    // ── SEARCH BUTTON ──────────────────────────────────────────────────────────
    @ViewBuilder
    var searchButtonSection: some View {
        Section {
            Button {
                Task {
                    await viewModel.search()
                    if !viewModel.results.isEmpty { showResults = true }
                }
            } label: {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView().tint(.black)
                    } else {
                        Text("Find Doubles \u2192")
                            .fontWeight(.bold)
                            .kerning(2)
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color(red: 0.78, green: 0.95, blue: 0.23))
            .foregroundColor(.black)
            .disabled(viewModel.isLoading || viewModel.params.selectedClubIds.isEmpty)

            if let error = viewModel.error {
                Text("\u26a0 \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .navigationDestination(isPresented: $showResults) {
            ResultsView(viewModel: viewModel)
        }
    }
}
