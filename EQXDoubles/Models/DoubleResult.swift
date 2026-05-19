// =============================================================================
// DoubleResult.swift
// EQX Doubles — iOS App
// =============================================================================
//
// WHAT IS `Codable`?
// Codable is a Swift protocol (actually a type alias for `Encodable & Decodable`)
// that lets Swift automatically convert your struct to/from JSON.
//
// When you conform to Codable, the Swift compiler generates the conversion code
// for you — you don't have to write any JSON parsing by hand. Magic!
//
// Example:
//   let json = """{"first_club_id": 102, "first_club_name": "Flatiron"}"""
//   let result = try JSONDecoder().decode(DoubleResult.self, from: jsonData)
//   // result.firstClubId == 102  ✓
//
// WHAT ARE `CodingKeys`?
// By default, Codable maps JSON keys to Swift property names directly.
// But our database returns snake_case (first_club_id) while Swift prefers
// camelCase (firstClubId). CodingKeys is an enum that creates that mapping.
//
// WHY IS `id` a `var` with a default value?
// The database doesn't return an `id` field — we generate one locally using
// UUID() so SwiftUI can use this struct in a List (Identifiable requires `id`).
// `var id: UUID = UUID()` means "this property is mutable, defaults to a new UUID".
//
// =============================================================================

import Foundation

// MARK: - DoubleResult Model

/// One "double" — a pair of back-to-back or near-back-to-back fitness classes.
/// This struct mirrors what the Supabase `find_doubles` RPC returns.
///
/// Conforms to:
///   • Codable     — can be decoded from the JSON the API returns
///   • Identifiable — has an `id` so SwiftUI can use it in Lists/ForEach
struct DoubleResult: Codable, Identifiable {

    // `var` because it's mutable (we set it after init); UUID() generates a
    // random unique identifier. The DB doesn't provide this — we make it locally.
    var id: UUID = UUID()

    // ── First Class ───────────────────────────────────────────────────────────
    let firstClubId: Int         // e.g. 102
    let firstClubName: String    // e.g. "Flatiron"
    let firstClubNbhd: String    // e.g. "Flatiron & Nomad"
    let firstClassName: String   // e.g. "Barre"
    let firstStart: Int          // minutes since midnight, e.g. 360 = 6:00 AM
    let firstEnd: Int            // minutes since midnight, e.g. 420 = 7:00 AM
    let firstInstructor: String? // OPTIONAL — the `?` means it can be nil (null)

    // ── Second Class ──────────────────────────────────────────────────────────
    let secondClubId: Int
    let secondClubName: String
    let secondClubNbhd: String
    let secondClassName: String
    let secondStart: Int         // gap starts after firstEnd
    let secondEnd: Int
    let secondInstructor: String?

    // ── Pair Metadata ─────────────────────────────────────────────────────────
    let gapMinutes: Int          // minutes between classes (0 = back-to-back)
    let sameClub: Bool           // true if both classes are at the same location

    // MARK: - CodingKeys

    // WHAT IS AN ENUM?
    // An enum (enumeration) is a type with a fixed set of named cases.
    // Here we use it to map JSON key names to Swift property names.
    //
    // CodingKeys must:
    //   1. Be named exactly `CodingKeys`
    //   2. Conform to `String, CodingKey`
    //   3. Have a case for EVERY property (except ones you want to skip)
    //
    // The `rawValue` string is the JSON key name from the database.
    // The case name is the Swift property name you want to use.
    //
    // WHY DOES `id` HAVE NO RAWVALUE?
    // We exclude `id` from CodingKeys entirely — that signals to Swift that
    // `id` is NOT decoded from JSON. It keeps its default value (UUID()).
    enum CodingKeys: String, CodingKey {
        case firstClubId      = "first_club_id"
        case firstClubName    = "first_club_name"
        case firstClubNbhd    = "first_club_nbhd"
        case firstClassName   = "first_class_name"
        case firstStart       = "first_start"
        case firstEnd         = "first_end"
        case firstInstructor  = "first_instructor"
        case secondClubId     = "second_club_id"
        case secondClubName   = "second_club_name"
        case secondClubNbhd   = "second_club_nbhd"
        case secondClassName  = "second_class_name"
        case secondStart      = "second_start"
        case secondEnd        = "second_end"
        case secondInstructor = "second_instructor"
        case gapMinutes       = "gap_minutes"
        case sameClub         = "same_club"
        // Note: `id` is intentionally OMITTED — it won't be decoded from JSON
    }
}

// MARK: - Time Formatting Helper

/// Converts an integer (minutes since midnight) into a human-readable time.
///
/// This is a FREE FUNCTION — it lives at the module level, not inside a type.
/// You call it as:  fmt(360)  →  "6:00 AM"
///                  fmt(810)  →  "1:30 PM"
///
/// WHAT IS `->` in a function signature?
/// The `->` means "this function RETURNS a value of this type".
///   func fmt(_ mins: Int) -> String
///   means: "a function named fmt that takes an Int and returns a String"
///
/// WHAT IS `_` (underscore) before a parameter name?
/// In Swift, function calls normally require parameter labels:
///   fmt(mins: 360)   ← with label
/// The underscore removes the external label requirement:
///   fmt(360)         ← no label needed
///
/// HOW DOES THE MATH WORK?
///   360 minutes → 360 / 60 = 6 hours, 360 % 60 = 0 minutes → "6:00 AM"
///   810 minutes → 810 / 60 = 13 hours → 1 PM, 810 % 60 = 30 minutes → "1:30 PM"
func fmt(_ mins: Int) -> String {
    // Integer division: 370 / 60 = 6 (drops remainder)
    let hour24 = mins / 60

    // Modulo (remainder): 370 % 60 = 10 (minutes past the hour)
    let minute = mins % 60

    // Convert 24-hour to 12-hour
    // hour24 == 0  →  12 AM (midnight)
    // hour24 == 12 →  12 PM (noon)
    // hour24 > 12  →  subtract 12 for PM hours
    let hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24)

    // Determine AM or PM
    let period = hour24 < 12 ? "AM" : "PM"

    // Format minutes with zero-padding using String(format:)
    // "%02d" means "at least 2 digits, pad with zero": 5 → "05", 30 → "30"
    let minuteStr = String(format: "%02d", minute)

    // String interpolation: \(variable) inserts a value into a string
    return "\(hour12):\(minuteStr) \(period)"
}
