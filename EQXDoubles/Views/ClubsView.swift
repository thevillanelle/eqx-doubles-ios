import SwiftUI

// Amenity data per club — matches the web app's clubs.html
let CLUB_AMENITIES: [Int: [String]] = [
    102: ["reformer","boxing","hyperice","spa","juice","coatcheck","shop"],
    103: ["boxing","kidclub","phystherapy","spa","juice","coatcheck","shop"],
    104: ["spa","juice","coatcheck","shop"],
    105: ["pool","sauna","boxing","cold","jacuzzi","spa","juice","coatcheck","shop"],
    106: ["juice","coatcheck","shop"],
    107: ["juice","shop"],
    108: ["juice","shop"],
    109: ["juice","coatcheck","shop"],
    110: ["pool","sauna","cold","spa","juice","coatcheck","shop"],
    111: ["pool","sauna","boxing","cold","jacuzzi","infrared","spa","juice","coatcheck","shop"],
    112: ["boxing","spa","juice","coatcheck","shop"],
    113: ["pool","sauna","boxing","cold","spa","juice","coatcheck","shop"],
    114: ["boxing","spa","juice","coatcheck","shop"],
    115: ["juice","coatcheck","shop"],
    116: ["pool","sauna","boxing","cold","jacuzzi","infrared","spa","juice","coatcheck","shop"],
    117: ["spa","juice","coatcheck","shop"],
    121: ["juice","coatcheck","shop"],
    122: ["juice","shop"],
    124: ["boxing","spa","juice","coatcheck","shop"],
    126: ["boxing","spa","juice","coatcheck","shop"],
    127: ["boxing","spa","juice","coatcheck","shop"],
    128: ["pool","sauna","cold","spa","juice","coatcheck","shop"],
    129: ["juice","coatcheck","shop"],
    130: ["boxing","spa","juice","coatcheck","shop"],
    131: ["pool","sauna","boxing","cold","jacuzzi","basketball","squash","spa","restaurant","juice","coatcheck","shop"],
    132: ["juice","coatcheck","shop"],
    133: ["juice","coatcheck","shop"],
    134: ["boxing","spa","juice","coatcheck","shop"],
    135: ["juice","shop"],
    136: ["juice","coatcheck","shop"],
    137: ["boxing","spa","juice","shop"],
    138: ["boxing","hyperice","spa","juice","coatcheck","shop"],
    139: ["juice","coatcheck","shop"],
    160: ["boxing","spa","juice","coatcheck","shop"],
    161: ["boxing","spa","juice","shop"],
    162: ["juice","shop"]
]

let DESTINATION_CLUBS: Set<Int> = [105, 110, 111, 113, 116, 128, 131]

let AMENITY_INFO: [(key: String, icon: String, label: String)] = [
    ("pool",       "🏊", "Pool"),
    ("sauna",      "🔥", "Dry Sauna"),
    ("boxing",     "🥊", "Boxing"),
    ("cold",       "🧊", "Cold Plunge"),
    ("reformer",   "🧘", "Reformer"),
    ("jacuzzi",    "🛁", "Jacuzzi"),
    ("infrared",   "🔆", "Infrared Sauna"),
    ("hyperice",   "🫧", "Hyperice"),
    ("kidclub",    "👶", "Kids Club"),
    ("spa",        "🧖", "Spa"),
    ("phystherapy","🏥", "Physical Therapy"),
    ("basketball", "🏀", "Basketball"),
    ("squash",     "🎾", "Squash"),
    ("restaurant", "🍽️", "Restaurant"),
    ("juice",      "🥤", "Juice Bar"),
    ("coatcheck",  "🧥", "Coat Check"),
    ("shop",       "🛍️", "Shop")
]

struct ClubsView: View {
    @State private var searchText = ""
    @State private var activeAmenity: String? = nil

    var filtered: [Club] {
        Club.allClubs.filter { club in
            let matchesSearch = searchText.isEmpty ||
                club.name.localizedCaseInsensitiveContains(searchText) ||
                club.neighborhood.localizedCaseInsensitiveContains(searchText)
            let matchesAmenity = activeAmenity == nil ||
                (CLUB_AMENITIES[club.id] ?? []).contains(activeAmenity!)
            return matchesSearch && matchesAmenity
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Search by name or neighborhood…", text: $searchText)
                }
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)

                // Amenity chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(AMENITY_INFO, id: \.key) { item in
                            Button {
                                activeAmenity = activeAmenity == item.key ? nil : item.key
                            } label: {
                                HStack(spacing: 4) {
                                    Text(item.icon).font(.system(size: 12))
                                    Text(item.label).font(.system(size: 12, weight: .semibold))
                                }
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(activeAmenity == item.key
                                    ? Color(red: 0.78, green: 0.95, blue: 0.23).opacity(0.15)
                                    : Color(.secondarySystemBackground))
                                .foregroundColor(activeAmenity == item.key
                                    ? Color(red: 0.78, green: 0.95, blue: 0.23)
                                    : .secondary)
                                .cornerRadius(20)
                                .overlay(RoundedRectangle(cornerRadius: 20)
                                    .stroke(activeAmenity == item.key
                                        ? Color(red: 0.78, green: 0.95, blue: 0.23)
                                        : Color.clear, lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal).padding(.vertical, 8)
                }

                Divider()

                // Count
                HStack {
                    Text("\(filtered.count) clubs")
                        .font(.system(size: 11, weight: .bold))
                        .kerning(2).textCase(.uppercase).foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal).padding(.vertical, 6)

                // Club list
                List(filtered) { club in
                    ClubCard(club: club)
                        .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
            .navigationTitle("NYC Clubs")
        }
    }
}

struct ClubCard: View {
    let club: Club
    let amenities: [String]
    let isDestination: Bool

    init(club: Club) {
        self.club = club
        self.amenities = CLUB_AMENITIES[club.id] ?? []
        self.isDestination = DESTINATION_CLUBS.contains(club.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(club.name)
                        .font(.system(size: 15, weight: .bold))
                    Text(club.neighborhood)
                        .font(.system(size: 12)).foregroundColor(.secondary)
                }
                Spacer()
                Text(isDestination ? "Destination" : "All Access")
                    .font(.system(size: 9, weight: .bold)).kerning(1)
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .background(isDestination
                        ? Color(red: 0.78, green: 0.95, blue: 0.23).opacity(0.15)
                        : Color(.tertiarySystemBackground))
                    .foregroundColor(isDestination
                        ? Color(red: 0.78, green: 0.95, blue: 0.23)
                        : .secondary)
                    .cornerRadius(4)
            }

            // Amenity tags
            if !amenities.isEmpty {
                let priorityAmenities = amenities.filter { ["pool","sauna","boxing","cold","reformer","jacuzzi","infrared","hyperice","kidclub","spa","phystherapy","basketball","squash","restaurant"].contains($0) }
                if !priorityAmenities.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(priorityAmenities, id: \.self) { key in
                                if let info = AMENITY_INFO.first(where: { $0.key == key }) {
                                    HStack(spacing: 3) {
                                        Text(info.icon).font(.system(size: 10))
                                        Text(info.label).font(.system(size: 10, weight: .medium))
                                    }
                                    .padding(.horizontal, 7).padding(.vertical, 3)
                                    .background(Color(.secondarySystemBackground))
                                    .foregroundColor(.primary)
                                    .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}
