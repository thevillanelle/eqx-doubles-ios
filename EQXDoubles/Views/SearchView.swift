import SwiftUI

// Helper view for one neighborhood row — avoids let-in-ViewBuilder issues
private struct NeighborhoodRow: View {
    let neighborhood: String
    @ObservedObject var viewModel: SearchViewModel

    private var clubsInNbhd: [Club] {
        Club.allClubs.filter { $0.neighborhood == neighborhood }
    }
    private var allSelected: Bool {
        clubsInNbhd.allSatisfy { viewModel.params.selectedClubIds.contains($0.id) }
    }

    var body: some View {
        DisclosureGroup {
            ForEach(clubsInNbhd) { club in
                Toggle(club.name, isOn: Binding(
                    get: { viewModel.params.selectedClubIds.contains(club.id) },
                    set: { on in
                        if on { viewModel.params.selectedClubIds.insert(club.id) }
                        else  { viewModel.params.selectedClubIds.remove(club.id) }
                    }
                ))
            }
        } label: {
            HStack {
                Text(neighborhood).font(.subheadline).foregroundColor(.primary)
                Spacer()
                Button(allSelected ? "Clear" : "All") {
                    if allSelected {
                        clubsInNbhd.forEach { viewModel.params.selectedClubIds.remove($0.id) }
                    } else {
                        clubsInNbhd.forEach { viewModel.params.selectedClubIds.insert($0.id) }
                    }
                }
                .font(.caption)
                .foregroundColor(Color(red: 0.78, green: 0.95, blue: 0.23))
                .buttonStyle(.plain)
            }
        }
    }
}

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @State private var showResults = false
    @State private var showDatePicker = false
    @AppStorage("isDark") private var isDark = true

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
            .navigationDestination(isPresented: $showResults) {
                ResultsView(viewModel: viewModel)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { isDark.toggle() } label: {
                        Image(systemName: isDark ? "sun.max" : "moon")
                            .foregroundColor(Color(red: 0.78, green: 0.95, blue: 0.23))
                    }
                }
            }
        }
    }

    @ViewBuilder
    var locationsSection: some View {
        Section {
            ForEach(Club.neighborhoods, id: \.self) { neighborhood in
                NeighborhoodRow(neighborhood: neighborhood, viewModel: viewModel)
            }
        } header: {
            HStack {
                Text("Locations")
                Spacer()
                Button(viewModel.params.selectedClubIds.count == Club.allClubs.count ? "Clear All" : "Select All") {
                    if viewModel.params.selectedClubIds.count == Club.allClubs.count {
                        viewModel.params.selectedClubIds = []
                    } else {
                        viewModel.params.selectedClubIds = Set(Club.allClubs.map { $0.id })
                    }
                }
                .font(.caption)
                .foregroundColor(Color(red: 0.78, green: 0.95, blue: 0.23))
                Text("· \(viewModel.params.selectedClubIds.count)")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    var classPairSection: some View {
        Section("Class Pair") {
            Picker("① First Class", selection: $viewModel.params.cat1) {
                ForEach(Category.allCategories) { cat in Text(cat.label).tag(cat.id) }
            }
            Picker("② Second Class", selection: $viewModel.params.cat2) {
                ForEach(Category.allCategories) { cat in Text(cat.label).tag(cat.id) }
            }
        }
    }

    @ViewBuilder
    var dateSection: some View {
        Section("Date") {
            if showDatePicker {
                DatePicker(
                    "Search Date",
                    selection: Binding(
                        get: { viewModel.params.date },
                        set: { newDate in
                            viewModel.params.date = newDate
                            withAnimation { showDatePicker = false }
                        }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(Color(red: 0.78, green: 0.95, blue: 0.23))
            } else {
                Button {
                    withAnimation { showDatePicker = true }
                } label: {
                    HStack {
                        Text("Search Date").foregroundColor(.primary)
                        Spacer()
                        Text(viewModel.params.date.formatted(date: .abbreviated, time: .omitted))
                            .foregroundColor(Color(red: 0.78, green: 0.95, blue: 0.23))
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.down").font(.caption).foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    var timeWindowSection: some View {
        Section("Time Window") {
            Picker("Time of Day", selection: Binding(
                get: {
                    if viewModel.params.winStart == 300  && viewModel.params.winEnd == 1380 { return "Any Time" }
                    if viewModel.params.winStart == 300  && viewModel.params.winEnd == 540  { return "Early AM" }
                    if viewModel.params.winStart == 540  && viewModel.params.winEnd == 720  { return "Late AM"  }
                    if viewModel.params.winStart == 720  && viewModel.params.winEnd == 900  { return "Afternoon" }
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
                    default: viewModel.params.winStart = 300; viewModel.params.winEnd = 1380
                    }
                }
            )) {
                Text("Any Time").tag("Any Time")
                Text("Early AM (5–9am)").tag("Early AM")
                Text("Late AM (9am–12pm)").tag("Late AM")
                Text("Afternoon (12–3pm)").tag("Afternoon")
                Text("Evening (6–9pm)").tag("Evening")
            }.pickerStyle(.menu)
        }
    }

    @ViewBuilder
    var gapSection: some View {
        Section("Max Gap") {
            Picker("Max Gap", selection: $viewModel.params.maxGap) {
                Text("≤15m").tag(15); Text("≤30m").tag(30)
                Text("≤45m").tag(45); Text("≤60m").tag(60)
            }.pickerStyle(.segmented)
        }
    }

    @ViewBuilder
    var orderSection: some View {
        Section("Pair Order") {
            Picker("Order", selection: $viewModel.params.pairOrder) {
                Text("Either").tag("either")
                Text("① → ②").tag("1first")
                Text("② → ①").tag("2first")
            }.pickerStyle(.segmented)
        }
    }

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
                    if viewModel.isLoading { ProgressView().tint(.black) }
                    else { Text("Find Doubles →").fontWeight(.bold).kerning(2) }
                    Spacer()
                }
            }
            .listRowBackground(Color(red: 0.78, green: 0.95, blue: 0.23))
            .foregroundColor(.black)
            .disabled(viewModel.isLoading || viewModel.params.selectedClubIds.isEmpty)
            if let error = viewModel.error {
                Text("⚠ \(error)").font(.caption).foregroundColor(.red)
            }
        }
    }
}
