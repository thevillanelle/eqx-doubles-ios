// =============================================================================
// SearchParams.swift
// EQX Doubles — iOS App
// =============================================================================
//
// This file defines two things:
//   1. SearchParams — all the user's current search filter settings
//   2. Category     — a fitness class category (barre, sculpt, etc.)
//
// Both are VALUE TYPES (structs). That means when you pass SearchParams to a
// function or assign it to another variable, Swift makes a COPY. The original
// is never accidentally mutated.
//
// WHAT IS `var` vs `let` inside a struct?
//   `let` properties are constants — set once at init, never changed.
//   `var` properties are mutable — can be changed after init.
//
// Since SearchParams holds the user's CHOICES (which change as they interact),
// all properties are `var` with sensible default values.
//
// DEFAULT VALUES:
// Each property has a default — `var cat1: String = "barre-all"` means if you
// create a SearchParams() with no arguments, cat1 will be "barre-all".
// =============================================================================

import Foundation

// MARK: - SearchParams

/// All search parameters the user can configure before running a search.
///
/// This is a pure data struct — no logic, no networking, just values.
/// The SearchViewModel reads these and passes them to SupabaseService.
struct SearchParams {

    // Which clubs the user has checked. Set<Int> = a collection of unique Ints.
    // A Set automatically prevents duplicates — you can't select the same club twice.
    var selectedClubIds: Set<Int> = []

    // Category IDs matching what the Supabase RPC expects.
    // These string values must match the `id` field in Category.allCategories.
    var cat1: String = "barre-all"       // First class in the pair (e.g., Barre)
    var cat2: String = "sculpt-all"      // Second class in the pair (e.g., Sculpt)

    // The date the user wants to search. Date() creates today's date.
    // The day-of-week (MONDAY, TUESDAY, etc.) is extracted from this in
    // SupabaseService.dayOfWeek(from:).
    var date: Date = Date()

    // Maximum allowed gap between the two classes, in minutes.
    var maxGap: Int = 30

    // Pair order: "either" = either class can be first
    //             "1first" = cat1 must be the first class
    //             "2first" = cat2 must be the first class
    var pairOrder: String = "either"

    // Time window: earliest and latest a pair can START, in minutes since midnight.
    // 300 = 5:00 AM, 1380 = 11:00 PM
    var winStart: Int = 300
    var winEnd: Int = 1380
}

// MARK: - Time Window Presets

/// Pre-defined time window shortcuts shown in the picker.
///
/// WHAT IS A TUPLE?
/// A tuple groups multiple values into one. `(start: Int, end: Int)` is a
/// tuple with two named fields. You access them as preset.start and preset.end.
struct TimeWindowPreset: Identifiable {
    let id: String    // unique key
    let label: String // human-readable name
    let start: Int    // minutes since midnight
    let end: Int      // minutes since midnight

    // Static array of all presets
    static let all: [TimeWindowPreset] = [
        TimeWindowPreset(id: "any",       label: "Any Time",      start: 300,  end: 1380),
        TimeWindowPreset(id: "early-am",  label: "Early Morning", start: 300,  end: 540),  // 5–9 AM
        TimeWindowPreset(id: "morning",   label: "Morning",       start: 480,  end: 720),  // 8 AM–12 PM
        TimeWindowPreset(id: "midday",    label: "Midday",        start: 660,  end: 840),  // 11 AM–2 PM
        TimeWindowPreset(id: "afternoon", label: "Afternoon",     start: 780,  end: 1020), // 1–5 PM
        TimeWindowPreset(id: "evening",   label: "Evening",       start: 960,  end: 1260), // 4–9 PM
    ]
}

// MARK: - Category Model

/// One fitness class category (e.g., "Barre", "Sculpt", "Cycling").
///
/// The `id` string matches exactly what the Supabase `find_doubles` RPC expects
/// as its `p_cat1` and `p_cat2` parameters.
struct Category: Identifiable {
    let id: String      // passed directly to the API, e.g. "barre-all"
    let label: String   // what the user sees, e.g. "Barre (any)"
    let group: String   // section header in the picker, e.g. "Barre"
}

// MARK: - All Categories

extension Category {

    /// All available class categories.
    /// These mirror the categories available in the web app version.
    ///
    /// Groups:
    ///   • Barre      — pure barre classes
    ///   • Sculpt     — strength/sculpt classes
    ///   • Cycling    — indoor cycling (Precision, Virtual)
    ///   • Pilates    — Pilates-based classes
    ///   • Yoga       — yoga (Vinyasa, Restorative, etc.)
    ///   • Cardio     — cardio-focused classes
    ///   • Strength   — weight training / HIIT
    ///   • Mind-Body  — meditation, stretch
    static let allCategories: [Category] = [

        // ── Barre ─────────────────────────────────────────────────────────────
        Category(id: "barre-all",        label: "Barre (any)",          group: "Barre"),
        Category(id: "barre",            label: "Barre",                group: "Barre"),
        Category(id: "barre-sculpt",     label: "Barre Sculpt",         group: "Barre"),
        Category(id: "cardio-barre",     label: "Cardio Barre",         group: "Barre"),

        // ── Sculpt ────────────────────────────────────────────────────────────
        Category(id: "sculpt-all",       label: "Sculpt (any)",         group: "Sculpt"),
        Category(id: "sculpt",           label: "Sculpt",               group: "Sculpt"),
        Category(id: "arms-abs",         label: "Arms & Abs",           group: "Sculpt"),

        // ── Cycling ───────────────────────────────────────────────────────────
        Category(id: "cycling-all",      label: "Cycling (any)",        group: "Cycling"),
        Category(id: "cycling",          label: "Cycling",              group: "Cycling"),
        Category(id: "precision-cycling",label: "Precision Cycling",    group: "Cycling"),
        Category(id: "virtual-cycling",  label: "Virtual Cycling",      group: "Cycling"),

        // ── Pilates ───────────────────────────────────────────────────────────
        Category(id: "pilates-all",      label: "Pilates (any)",        group: "Pilates"),
        Category(id: "pilates",          label: "Pilates",              group: "Pilates"),
        Category(id: "mat-pilates",      label: "Mat Pilates",          group: "Pilates"),
        Category(id: "reformer-pilates", label: "Reformer Pilates",     group: "Pilates"),

        // ── Yoga ──────────────────────────────────────────────────────────────
        Category(id: "yoga-all",         label: "Yoga (any)",           group: "Yoga"),
        Category(id: "vinyasa",          label: "Vinyasa Yoga",         group: "Yoga"),
        Category(id: "restorative-yoga", label: "Restorative Yoga",     group: "Yoga"),
        Category(id: "yoga-sculpt",      label: "Yoga Sculpt",          group: "Yoga"),

        // ── Cardio ────────────────────────────────────────────────────────────
        Category(id: "cardio-all",       label: "Cardio (any)",         group: "Cardio"),
        Category(id: "hiit",             label: "HIIT",                 group: "Cardio"),
        Category(id: "boxing",           label: "Boxing",               group: "Cardio"),
        Category(id: "dance",            label: "Dance Cardio",         group: "Cardio"),

        // ── Strength ──────────────────────────────────────────────────────────
        Category(id: "strength-all",     label: "Strength (any)",       group: "Strength"),
        Category(id: "strength",         label: "Strength",             group: "Strength"),
        Category(id: "kettlebell",       label: "Kettlebell",           group: "Strength"),

        // ── Mind-Body ─────────────────────────────────────────────────────────
        Category(id: "stretch",          label: "Stretch",              group: "Mind-Body"),
        Category(id: "meditation",       label: "Meditation",           group: "Mind-Body"),
    ]

    /// Groups categories by their `group` field for sectioned pickers.
    /// Returns a dictionary: { "Barre": [...], "Cycling": [...], ... }
    static var byGroup: [String: [Category]] {
        Dictionary(grouping: allCategories, by: { $0.group })
    }

    /// Sorted list of unique group names.
    static var groups: [String] {
        // Keep insertion order by using the first appearance of each group
        var seen = Set<String>()
        return allCategories.compactMap { cat in
            // `insert` returns (inserted: Bool, memberAfterInsert: String)
            // If `inserted` is true, this is the first time we've seen this group
            seen.insert(cat.group).inserted ? cat.group : nil
        }
    }
}
