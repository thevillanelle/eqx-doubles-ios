import SwiftUI

// MARK: - Amenity Model

enum Amenity: String, CaseIterable, Identifiable {
    case pool, sauna, boxing, cold, jacuzzi, reformer, infrared
    case basketball, squash, hyperice, spa, restaurant, juice, coatcheck, shop
    case phystherapy, kidclub

    var id: String { rawValue }

    var label: String {
        switch self {
        case .pool: return "Pool"
        case .sauna: return "Sauna"
        case .boxing: return "Boxing"
        case .cold: return "Cold Plunge"
        case .jacuzzi: return "Jacuzzi"
        case .reformer: return "Reformer"
        case .infrared: return "Infrared"
        case .basketball: return "Basketball"
        case .squash: return "Squash"
        case .hyperice: return "Hyperice"
        case .spa: return "Spa"
        case .restaurant: return "Restaurant"
        case .juice: return "Juice Bar"
        case .coatcheck: return "Coat Check"
        case .shop: return "Shop"
        case .phystherapy: return "PT"
        case .kidclub: return "Kids Club"
        }
    }

    var icon: String {
        switch self {
        case .pool: return "drop.fill"
        case .sauna: return "flame.fill"
        case .boxing: return "figure.boxing"
        case .cold: return "snowflake"
        case .jacuzzi: return "bubble.left.fill"
        case .reformer: return "figure.pilates"
        case .infrared: return "sun.max.fill"
        case .basketball: return "basketball.fill"
        case .squash: return "sportscourt.fill"
        case .hyperice: return "bolt.fill"
        case .spa: return "sparkles"
        case .restaurant: return "fork.knife"
        case .juice: return "cup.and.saucer.fill"
        case .coatcheck: return "bag.fill"
        case .shop: return "cart.fill"
        case .phystherapy: return "cross.fill"
        case .kidclub: return "star.fill"
        }
    }
}

// MARK: - Club Directory Entry

struct ClubEntry: Identifiable {
    let id: Int
    let name: String
    let shortName: String
    let neighborhood: String
    let address: String
    let amenities: [Amenity]
    let isDestination: Bool
}

// MARK: - Club Data

let allClubEntries: [ClubEntry] = [
    ClubEntry(id: 102, name: "Equinox Flatiron", shortName: "Flatiron",
              neighborhood: "Flatiron", address: "897 Broadway",
              amenities: [.reformer, .boxing, .hyperice, .spa, .juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 103, name: "Equinox W 92nd", shortName: "W 92nd",
              neighborhood: "Upper West Side", address: "2465 Broadway",
              amenities: [.boxing, .kidclub, .phystherapy, .spa, .juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 104, name: "Equinox E 85th", shortName: "E 85th",
              neighborhood: "Upper East Side", address: "205 E 85th St",
              amenities: [.spa, .juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 105, name: "Equinox E 63rd", shortName: "E 63rd",
              neighborhood: "Upper East Side", address: "200 E 63rd St",
              amenities: [.pool, .sauna, .boxing, .cold, .jacuzzi, .spa, .juice, .coatcheck, .shop],
              isDestination: true),
    ClubEntry(id: 106, name: "Equinox E 54th", shortName: "E 54th",
              neighborhood: "Midtown East", address: "250 E 54th St",
              amenities: [.juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 107, name: "Equinox W 50th", shortName: "W 50th",
              neighborhood: "Midtown West", address: "1633 Broadway",
              amenities: [.juice, .shop],
              isDestination: false),
    ClubEntry(id: 108, name: "Equinox E 43rd", shortName: "E 43rd",
              neighborhood: "Midtown East", address: "230 E 43rd St",
              amenities: [.juice, .shop],
              isDestination: false),
    ClubEntry(id: 109, name: "Equinox E 44th", shortName: "E 44th",
              neighborhood: "Grand Central", address: "320 Park Ave",
              amenities: [.juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 110, name: "Equinox Wall Street", shortName: "Wall St",
              neighborhood: "FiDi", address: "14 Wall St",
              amenities: [.pool, .sauna, .cold, .spa, .juice, .coatcheck, .shop],
              isDestination: true),
    ClubEntry(id: 111, name: "Equinox Tribeca", shortName: "Tribeca",
              neighborhood: "Tribeca", address: "54 Murray St",
              amenities: [.pool, .sauna, .boxing, .cold, .jacuzzi, .infrared, .spa, .juice, .coatcheck, .shop],
              isDestination: true),
    ClubEntry(id: 112, name: "Equinox Greenwich Ave", shortName: "Greenwich Ave",
              neighborhood: "West Village", address: "97 Greenwich Ave",
              amenities: [.boxing, .spa, .juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 113, name: "Equinox Columbus Ave", shortName: "Columbus Ave",
              neighborhood: "Upper West Side", address: "2178 Broadway",
              amenities: [.pool, .sauna, .boxing, .cold, .spa, .juice, .coatcheck, .shop],
              isDestination: true),
    ClubEntry(id: 114, name: "Equinox SoHo", shortName: "SoHo",
              neighborhood: "SoHo", address: "568 Broadway",
              amenities: [.boxing, .spa, .juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 115, name: "Equinox Park Ave", shortName: "Park Ave",
              neighborhood: "Midtown East", address: "897 Park Ave",
              amenities: [.juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 116, name: "Equinox High Line", shortName: "High Line",
              neighborhood: "Chelsea", address: "95 10th Ave",
              amenities: [.pool, .sauna, .boxing, .cold, .jacuzzi, .infrared, .spa, .juice, .coatcheck, .shop],
              isDestination: true),
    ClubEntry(id: 117, name: "Equinox E 74th", shortName: "E 74th",
              neighborhood: "Upper East Side", address: "344 Amsterdam Ave",
              amenities: [.spa, .juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 121, name: "Equinox W 76th", shortName: "W 76th",
              neighborhood: "Upper West Side", address: "2465 Broadway",
              amenities: [.juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 122, name: "Equinox Orchard Street", shortName: "Orchard St",
              neighborhood: "Lower East Side", address: "174 Orchard St",
              amenities: [.juice, .shop],
              isDestination: false),
    ClubEntry(id: 124, name: "Equinox Printing House", shortName: "Printing House",
              neighborhood: "West Village", address: "421 Hudson St",
              amenities: [.boxing, .spa, .juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 126, name: "Equinox Rock Center", shortName: "Rock Center",
              neighborhood: "Midtown", address: "45 Rockefeller Plaza",
              amenities: [.boxing, .spa, .juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 127, name: "Equinox Bryant Park", shortName: "Bryant Park",
              neighborhood: "Midtown", address: "1065 Ave of the Americas",
              amenities: [.boxing, .spa, .juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 128, name: "Equinox Brookfield Place", shortName: "Brookfield",
              neighborhood: "FiDi", address: "225 Liberty St",
              amenities: [.pool, .sauna, .cold, .spa, .juice, .coatcheck, .shop],
              isDestination: true),
    ClubEntry(id: 129, name: "Equinox E 92nd", shortName: "E 92nd",
              neighborhood: "Upper East Side", address: "151 E 92nd St",
              amenities: [.juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 130, name: "Equinox Brooklyn Heights", shortName: "Bklyn Heights",
              neighborhood: "Brooklyn Heights", address: "194 Joralemon St",
              amenities: [.boxing, .spa, .juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 131, name: "Equinox Sports Club NY", shortName: "Sports Club NY",
              neighborhood: "Upper East Side", address: "330 E 61st St",
              amenities: [.pool, .sauna, .boxing, .cold, .jacuzzi, .basketball, .squash, .spa, .restaurant, .juice, .coatcheck, .shop],
              isDestination: true),
    ClubEntry(id: 132, name: "Equinox E 61st", shortName: "E 61st",
              neighborhood: "Upper East Side", address: "817 Lexington Ave",
              amenities: [.juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 133, name: "Equinox E 53rd", shortName: "E 53rd",
              neighborhood: "Midtown East", address: "521 5th Ave",
              amenities: [.juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 134, name: "Equinox DUMBO", shortName: "DUMBO",
              neighborhood: "DUMBO", address: "55 Water St",
              amenities: [.boxing, .spa, .juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 135, name: "Equinox Bond Street", shortName: "Bond St",
              neighborhood: "NoHo", address: "10 Bond St",
              amenities: [.juice, .shop],
              isDestination: false),
    ClubEntry(id: 136, name: "Equinox Gramercy", shortName: "Gramercy",
              neighborhood: "Gramercy", address: "90 E 18th St",
              amenities: [.juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 137, name: "Equinox Williamsburg", shortName: "Williamsburg",
              neighborhood: "Williamsburg", address: "247 Metropolitan Ave",
              amenities: [.boxing, .spa, .juice, .shop],
              isDestination: false),
    ClubEntry(id: 138, name: "Equinox Hudson Yards", shortName: "Hudson Yards",
              neighborhood: "Hudson Yards", address: "20 Hudson Yards",
              amenities: [.boxing, .hyperice, .spa, .juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 139, name: "Equinox E Madison", shortName: "E Madison",
              neighborhood: "Midtown East", address: "252 E 57th St",
              amenities: [.juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 160, name: "Equinox NoMad", shortName: "NoMad",
              neighborhood: "NoMad", address: "1185 Broadway",
              amenities: [.boxing, .spa, .juice, .coatcheck, .shop],
              isDestination: false),
    ClubEntry(id: 161, name: "Equinox Domino", shortName: "Domino",
              neighborhood: "Williamsburg", address: "264 Kent Ave",
              amenities: [.boxing, .spa, .juice, .shop],
              isDestination: false),
    ClubEntry(id: 162, name: "Equinox Hudson Square", shortName: "Hudson Square",
              neighborhood: "Hudson Square", address: "315 Hudson St",
              amenities: [.juice, .shop],
              isDestination: false),
]

// MARK: - Club Card View

struct ClubCardView: View {
    let club: ClubEntry

    private let limeGreen = Color(red: 0.78, green: 0.95, blue: 0.23)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(club.shortName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text(club.neighborhood)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(club.address)
                        .font(.system(size: 11))
                        .foregroundColor(Color.gray.opacity(0.7))
                }
                Spacer()
                // Access badge
                Text(club.isDestination ? "Destination" : "All Access")
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(club.isDestination ? limeGreen.opacity(0.15) : Color.white.opacity(0.07))
                    .foregroundColor(club.isDestination ? limeGreen : .gray)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(
                            club.isDestination ? limeGreen.opacity(0.4) : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                    )
            }

            // Amenity chips
            FlowLayout(spacing: 6) {
                ForEach(club.amenities) { amenity in
                    HStack(spacing: 4) {
                        Image(systemName: amenity.icon)
                            .font(.system(size: 9))
                        Text(amenity.label)
                            .font(.system(size: 10))
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.06))
                    .foregroundColor(Color.gray.opacity(0.9))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.18, green: 0.18, blue: 0.18), lineWidth: 1)
        )
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Clubs View

struct ClubsView: View {
    @State private var searchText = ""
    @State private var selectedAmenities: Set<Amenity> = []

    private let limeGreen = Color(red: 0.78, green: 0.95, blue: 0.23)

    private var filterAmenities: [Amenity] {
        [.pool, .sauna, .boxing, .cold, .jacuzzi, .reformer, .infrared, .spa, .basketball, .squash, .hyperice]
    }

    private var filteredClubs: [ClubEntry] {
        allClubEntries.filter { club in
            let matchesSearch = searchText.isEmpty ||
                club.name.localizedCaseInsensitiveContains(searchText) ||
                club.shortName.localizedCaseInsensitiveContains(searchText) ||
                club.neighborhood.localizedCaseInsensitiveContains(searchText)
            let matchesAmenities = selectedAmenities.isEmpty ||
                selectedAmenities.allSatisfy { club.amenities.contains($0) }
            return matchesSearch && matchesAmenities
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                            TextField("Search clubs or neighborhoods...", text: $searchText)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .tint(limeGreen)
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 0.2, green: 0.2, blue: 0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        // Amenity filter chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(filterAmenities) { amenity in
                                    let isSelected = selectedAmenities.contains(amenity)
                                    Button {
                                        if isSelected {
                                            selectedAmenities.remove(amenity)
                                        } else {
                                            selectedAmenities.insert(amenity)
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: amenity.icon)
                                                .font(.system(size: 10))
                                            Text(amenity.label)
                                                .font(.system(size: 11, weight: .medium))
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(isSelected ? limeGreen.opacity(0.2) : Color(red: 0.15, green: 0.15, blue: 0.15))
                                        .foregroundColor(isSelected ? limeGreen : .gray)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule().stroke(
                                                isSelected ? limeGreen.opacity(0.5) : Color.white.opacity(0.08),
                                                lineWidth: 1
                                            )
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // Result count
                        HStack {
                            Text("\(filteredClubs.count) clubs")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            if !selectedAmenities.isEmpty {
                                Text("· \(selectedAmenities.count) filter\(selectedAmenities.count == 1 ? "" : "s") active")
                                    .font(.system(size: 11))
                                    .foregroundColor(limeGreen)
                                Button("Clear") {
                                    selectedAmenities = []
                                }
                                .font(.system(size: 11))
                                .foregroundColor(limeGreen)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 16)

                        // Club cards
                        LazyVStack(spacing: 10) {
                            ForEach(filteredClubs) { club in
                                ClubCardView(club: club)
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("NYC Clubs")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}