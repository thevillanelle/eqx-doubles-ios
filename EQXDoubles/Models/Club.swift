// =============================================================================
// Club.swift
// EQX Doubles — iOS App
// =============================================================================
//
// WHAT IS A STRUCT?
// A struct (short for "structure") is a value type that groups related data
// together. Think of it like a Python dataclass or a JavaScript object literal,
// but with one key difference: structs are COPIED when you assign them.
//
//   var a = Club(id: 1, name: "Flatiron", ...)
//   var b = a        // b is a COPY — changing b does NOT change a
//
// In Swift, structs are the preferred way to model data. Use a class when you
// need reference semantics (shared, mutable state across many places).
//
// WHAT IS A PROTOCOL?
// A protocol is like an interface or contract. It says "anything that conforms
// to me MUST have these properties/methods." Here we conform to two protocols:
//
//   • Identifiable — the struct has an `id` property. SwiftUI uses this to
//     track items in Lists and ForEach loops efficiently.
//
//   • Hashable — two Club values can be compared for equality and stored in
//     Sets or used as Dictionary keys. We need this for Set<Int> of club IDs.
//
// =============================================================================

import Foundation

// MARK: - Club Model

/// Represents one Equinox club location.
///
/// The `let` keyword means these properties are CONSTANTS — once a Club is
/// created, its data never changes. This is immutability, a core Swift value.
struct Club: Identifiable, Hashable {
    let id: Int               // Unique numeric ID matching the Supabase database
    let name: String          // Display name, e.g. "Flatiron"
    let neighborhood: String  // Neighborhood group, e.g. "Flatiron & Nomad"
    let lat: Double           // Latitude for future map features
    let lng: Double           // Longitude for future map features
}

// MARK: - Static Club Data

/// An `extension` lets you add new functionality to an existing type — even
/// types you didn't write (like String or Array). Here we extend Club to add
/// a static array of all NYC Equinox locations.
///
/// `static` means the property belongs to the TYPE itself, not to any instance.
/// You access it as Club.allClubs, not myClub.allClubs.
extension Club {

    // WHAT IS `static let`?
    // `static` = belongs to Club as a type, not to any particular Club value
    // `let`    = constant — this array never changes after it's created
    // The array is initialized once the first time Club.allClubs is accessed,
    // then cached in memory forever (Swift's default lazy-static behavior).
    static let allClubs: [Club] = [

        // ── Downtown & Tribeca ────────────────────────────────────────────
        Club(id: 110, name: "Wall Street",        neighborhood: "Downtown & Tribeca",     lat: 40.7074, lng: -74.0113),
        Club(id: 128, name: "Brookfield Place",   neighborhood: "Downtown & Tribeca",     lat: 40.7127, lng: -74.0159),
        Club(id: 111, name: "Tribeca",            neighborhood: "Downtown & Tribeca",     lat: 40.7163, lng: -74.0086),

        // ── LES & SoHo ───────────────────────────────────────────────────
        Club(id: 122, name: "Orchard Street",     neighborhood: "LES & SoHo",             lat: 40.7196, lng: -73.9897),
        Club(id: 114, name: "SoHo",               neighborhood: "LES & SoHo",             lat: 40.7244, lng: -74.0010),

        // ── West Village & Chelsea ────────────────────────────────────────
        Club(id: 135, name: "Bond Street",        neighborhood: "West Village & Chelsea", lat: 40.7254, lng: -73.9928),
        Club(id: 124, name: "Printing House",     neighborhood: "West Village & Chelsea", lat: 40.7285, lng: -74.0060),
        Club(id: 162, name: "Hudson Square",      neighborhood: "West Village & Chelsea", lat: 40.7269, lng: -74.0047),
        Club(id: 112, name: "Greenwich Avenue",   neighborhood: "West Village & Chelsea", lat: 40.7358, lng: -74.0001),
        Club(id: 116, name: "High Line",          neighborhood: "West Village & Chelsea", lat: 40.7465, lng: -74.0014),

        // ── Flatiron & Nomad ──────────────────────────────────────────────
        Club(id: 102, name: "Flatiron",           neighborhood: "Flatiron & Nomad",       lat: 40.7401, lng: -73.9894),
        Club(id: 136, name: "Gramercy",           neighborhood: "Flatiron & Nomad",       lat: 40.7381, lng: -73.9833),
        Club(id: 160, name: "Nomad",              neighborhood: "Flatiron & Nomad",       lat: 40.7447, lng: -73.9879),

        // ── Hudson Yards ─────────────────────────────────────────────────
        Club(id: 138, name: "Hudson Yards",       neighborhood: "Hudson Yards",           lat: 40.7537, lng: -74.0021),

        // ── Midtown South ─────────────────────────────────────────────────
        Club(id: 127, name: "Bryant Park",        neighborhood: "Midtown South",          lat: 40.7540, lng: -73.9832),
        Club(id: 108, name: "East 43rd Street",   neighborhood: "Midtown South",          lat: 40.7527, lng: -73.9769),
        Club(id: 109, name: "East 44th Street",   neighborhood: "Midtown South",          lat: 40.7534, lng: -73.9760),

        // ── Midtown East ──────────────────────────────────────────────────
        Club(id: 126, name: "Rockefeller Center", neighborhood: "Midtown East",           lat: 40.7587, lng: -73.9787),
        Club(id: 133, name: "East 53rd Street",   neighborhood: "Midtown East",           lat: 40.7592, lng: -73.9697),
        Club(id: 106, name: "East 54th Street",   neighborhood: "Midtown East",           lat: 40.7601, lng: -73.9686),
        Club(id: 115, name: "Park Avenue",        neighborhood: "Midtown East",           lat: 40.7573, lng: -73.9729),
        Club(id: 139, name: "E Madison Avenue",   neighborhood: "Midtown East",           lat: 40.7614, lng: -73.9741),

        // ── Midtown West ──────────────────────────────────────────────────
        Club(id: 107, name: "West 50th Street",   neighborhood: "Midtown West",           lat: 40.7609, lng: -73.9820),
        Club(id: 113, name: "Columbus Circle",    neighborhood: "Midtown West",           lat: 40.7680, lng: -73.9819),

        // ── Upper East Side ───────────────────────────────────────────────
        Club(id: 132, name: "East 61st Street",   neighborhood: "Upper East Side",        lat: 40.7634, lng: -73.9649),
        Club(id: 105, name: "East 63rd Street",   neighborhood: "Upper East Side",        lat: 40.7648, lng: -73.9644),
        Club(id: 117, name: "East 74th Street",   neighborhood: "Upper East Side",        lat: 40.7716, lng: -73.9572),
        Club(id: 104, name: "East 85th Street",   neighborhood: "Upper East Side",        lat: 40.7789, lng: -73.9539),
        Club(id: 129, name: "East 92nd Street",   neighborhood: "Upper East Side",        lat: 40.7834, lng: -73.9497),
        Club(id: 131, name: "Sports Club NY",     neighborhood: "Upper East Side",        lat: 40.7647, lng: -73.9638),

        // ── Upper West Side ───────────────────────────────────────────────
        Club(id: 121, name: "West 76th Street",   neighborhood: "Upper West Side",        lat: 40.7805, lng: -73.9813),
        Club(id: 103, name: "West 92nd Street",   neighborhood: "Upper West Side",        lat: 40.7907, lng: -73.9749),

        // ── Brooklyn ─────────────────────────────────────────────────────
        Club(id: 130, name: "Brooklyn Heights",   neighborhood: "Brooklyn",               lat: 40.6962, lng: -73.9934),
        Club(id: 134, name: "DUMBO",              neighborhood: "Brooklyn",               lat: 40.7033, lng: -73.9886),
        Club(id: 161, name: "Domino",             neighborhood: "Brooklyn",               lat: 40.7126, lng: -73.9673),
        Club(id: 137, name: "Williamsburg",       neighborhood: "Brooklyn",               lat: 40.7131, lng: -73.9626),
    ]

    // MARK: - Neighborhood Grouping

    /// Groups all clubs by neighborhood.
    ///
    /// WHAT IS A COMPUTED PROPERTY?
    /// Instead of storing a value, a computed property runs code every time
    /// you access it and RETURNS a value. The `var` keyword + `{ ... }` block
    /// (with no `=`) signals a computed property.
    ///
    /// WHAT IS Dictionary(grouping:by:)?
    /// It's a Swift initializer that takes an array and a closure, then groups
    /// array elements into a Dictionary keyed by whatever the closure returns.
    ///
    /// WHAT IS A CLOSURE?
    /// A closure is an anonymous (nameless) function you pass as a value.
    ///   { $0.neighborhood }   means   { (club: Club) -> String in club.neighborhood }
    /// Swift lets you use $0 as shorthand for "the first argument".
    static var byNeighborhood: [String: [Club]] {
        Dictionary(grouping: allClubs, by: { $0.neighborhood })
    }

    /// A sorted list of unique neighborhood names for section headers.
    /// 1. map → extract each club's neighborhood string
    /// 2. Set → remove duplicates (sets can't have duplicates)
    /// 3. Array → convert back to array so we can sort
    /// 4. .sorted() → alphabetical order
    static var neighborhoods: [String] {
        Array(Set(allClubs.map { $0.neighborhood })).sorted()
    }
}
