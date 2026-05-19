// =============================================================================
// ResultCard.swift
// EQX Doubles — iOS App
// =============================================================================
//
// WHAT IS A VIEW IN SWIFTUI?
// A View is a protocol that represents a piece of UI. Every screen, button,
// text label, image, and layout container in SwiftUI is a View.
//
// To create a View, you make a struct that conforms to the View protocol:
//   struct MyView: View {
//       var body: some View { ... }
//   }
//
// WHAT IS `body`?
// `body` is the one required property of the View protocol. It describes
// WHAT the view looks like. SwiftUI calls body whenever it needs to render
// (or re-render) your view.
//
// WHAT IS `some View`?
// `some View` is an "opaque return type." It means: "I return SOME specific
// type that conforms to View, but I won't tell you exactly which type."
// This lets you write complex view hierarchies without spelling out the full
// nested generic type (which would be enormous and unreadable).
//
// DESIGN PHILOSOPHY:
// ResultCard is a "dumb" view — it takes a DoubleResult and displays it.
// It has NO logic, NO state, NO network calls. It just renders data.
// This makes it easy to preview, test, and reuse.
// =============================================================================

import SwiftUI

// MARK: - Color Constants

// Color constants for the EQX Doubles design system.
// These are defined as computed properties on Color using extension.
//
// WHAT IS `Color(hex:)`?
// SwiftUI's Color doesn't have a hex initializer built in, so we add one
// (see the extension at the bottom of this file).
extension Color {
    // The signature lime green from the EQX Doubles web app
    static let eqxLime = Color(hex: "#C8F23A")

    // Dark background colors
    static let cardBackground = Color(hex: "#1A1A1A")
    static let cardBorder = Color(hex: "#2E2E2E")
    static let surfaceColor = Color(hex: "#111111")

    // Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#999999")
    static let textMuted = Color(hex: "#666666")
}

// MARK: - ResultCard

/// A card view displaying one pair of back-to-back fitness classes.
///
/// WHAT IS A `let` PROPERTY ON A VIEW?
/// Unlike @State properties (which SwiftUI manages), a plain `let` on a View
/// is just data passed in from the parent. It's read-only — this view displays
/// the result but never modifies it.
struct ResultCard: View {

    // The double result to display. Passed in by the parent (ResultsView).
    // `let` because this view doesn't modify the result — it just shows it.
    let result: DoubleResult

    // MARK: - Body

    /// Describes the card's visual layout.
    ///
    /// WHAT IS `var body: some View`?
    /// It's the required property every View must implement. SwiftUI calls this
    /// to know what to draw on screen. The return type `some View` means SwiftUI
    /// doesn't care exactly which View type comes back, as long as it's a View.
    var body: some View {

        // VStack = Vertical Stack
        // Arranges its children in a vertical column (top to bottom).
        // `alignment: .leading` = align children to the left edge
        // `spacing: 0` = no gap between children (we'll add padding manually)
        //
        // WHAT IS `alignment` in VStack?
        // It controls horizontal alignment of children inside the stack:
        //   .leading  = left-aligned
        //   .center   = centered
        //   .trailing = right-aligned
        VStack(alignment: .leading, spacing: 0) {

            // ── Header Row ────────────────────────────────────────────────
            headerRow

            // Divider with subtle color
            Rectangle()
                .fill(Color.cardBorder)
                .frame(height: 1)

            // ── Class Cells ───────────────────────────────────────────────
            // On iPhone (compact width) stack vertically.
            // We use a simple VStack for the iPhone-first layout.
            classCellsStack
        }
        // .background() sets the background fill
        .background(Color.cardBackground)
        // .cornerRadius() rounds the corners
        .cornerRadius(12)
        // .overlay() draws OVER the view — here we draw a border
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
        // .padding(.horizontal) adds left/right breathing room
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    // MARK: - Header Row

    /// The top row showing location info and gap label.
    ///
    /// WHAT IS A COMPUTED PROPERTY ON A VIEW?
    /// Breaking the body into smaller computed properties (like `headerRow`)
    /// is a common SwiftUI pattern. It keeps body readable without creating
    /// entirely separate View files for every sub-section.
    private var headerRow: some View {
        HStack(alignment: .center) {

            // Location label
            Text(locationLabel)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.textPrimary)
                .lineLimit(1)  // Don't wrap — truncate with ellipsis

            // Spacer() is a flexible empty view that fills all available space.
            // It pushes the location left and the gap label right.
            Spacer()

            // Gap badge
            gapBadge
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - Location Label

    /// Either "Flatiron" (same club) or "Flatiron → Bryant Park" (different clubs).
    ///
    /// WHAT IS A TERNARY EXPRESSION?
    /// condition ? valueIfTrue : valueIfFalse
    /// It's a compact if/else that returns a value.
    private var locationLabel: String {
        result.sameClub
            ? result.firstClubName
            : "\(result.firstClubName) → \(result.secondClubName)"
    }

    // MARK: - Gap Badge

    /// A pill-shaped label showing the gap time.
    private var gapBadge: some View {
        Text(gapLabel)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(result.gapMinutes == 0 ? Color.black : Color.eqxLime)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            // Background changes based on gap: lime for back-to-back, outline otherwise
            .background(
                result.gapMinutes == 0
                    ? Color.eqxLime
                    : Color.eqxLime.opacity(0.12)
            )
            .cornerRadius(100) // fully rounded pill
            .overlay(
                Capsule()
                    .stroke(Color.eqxLime.opacity(result.gapMinutes == 0 ? 0 : 0.4), lineWidth: 1)
            )
    }

    /// Text for the gap label.
    private var gapLabel: String {
        result.gapMinutes == 0 ? "Back-to-back" : "+\(result.gapMinutes) min"
    }

    // MARK: - Class Cells (Stacked)

    /// Two class cells stacked vertically (iPhone layout).
    private var classCellsStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            ClassCell(
                clubName: result.firstClubName,
                className: result.firstClassName,
                start: result.firstStart,
                end: result.firstEnd,
                instructor: result.firstInstructor,
                isFirst: true,
                sameClub: result.sameClub
            )

            Rectangle()
                .fill(Color.cardBorder)
                .frame(height: 1)

            ClassCell(
                clubName: result.secondClubName,
                className: result.secondClassName,
                start: result.secondStart,
                end: result.secondEnd,
                instructor: result.secondInstructor,
                isFirst: false,
                sameClub: result.sameClub
            )
        }
    }
}

// MARK: - ClassCell

/// Displays one class within a double pair.
///
/// WHAT IS A SEPARATE SUB-VIEW STRUCT?
/// Breaking complex views into smaller pieces (like ClassCell here) is a best
/// practice. Benefits:
///   • Smaller, more readable code blocks
///   • SwiftUI only re-renders the smallest changed piece
///   • Easier to test and preview in isolation
struct ClassCell: View {
    let clubName: String
    let className: String
    let start: Int
    let end: Int
    let instructor: String?
    let isFirst: Bool      // true = first class, false = second class
    let sameClub: Bool     // true = both classes at same club (don't repeat club name)

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // Left: numbered circle (1 or 2)
            ZStack {
                // ZStack = Z-axis Stack (layers on top of each other)
                Circle()
                    .fill(isFirst ? Color.eqxLime : Color.eqxLime.opacity(0.2))
                    .frame(width: 24, height: 24)
                Text(isFirst ? "1" : "2")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isFirst ? .black : .eqxLime)
            }
            .padding(.top, 2) // align with first line of text

            // Right: class details
            VStack(alignment: .leading, spacing: 3) {

                // Class name
                Text(className)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)

                // Time range — lime green like the web app
                Text("\(fmt(start)) – \(fmt(end))")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(.eqxLime)

                // Club name (only show for second class if different clubs)
                if !sameClub {
                    Text(clubName)
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }

                // Instructor (optional — might be nil if unknown)
                //
                // WHAT IS `if let`?
                // `if let name = instructor` safely unwraps the Optional.
                // If `instructor` is nil, the block is skipped entirely.
                // If `instructor` has a value, `name` is that value (non-optional).
                if let name = instructor {
                    Text("with \(name)")
                        .font(.system(size: 12))
                        .foregroundColor(.textMuted)
                }
            }

            Spacer() // push content left
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

// MARK: - Color Hex Extension

/// Adds a hex string initializer to SwiftUI's Color.
///
/// WHAT IS AN EXTENSION?
/// An extension adds new functionality to an existing type. Here we add a
/// `init(hex:)` initializer that Swift's Color type doesn't have built-in.
///
/// WHAT IS `init`?
/// An initializer creates a new instance of a type. `Color(hex: "#FF0000")`
/// calls this custom initializer.
extension Color {
    init(hex: String) {
        // Clean the string: remove # prefix, trim whitespace
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)

        // Convert the hex string to a single 32-bit unsigned integer
        // "C8F23A" → 13,168,954 → 0x00C8F23A
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        // Extract the red, green, blue components
        // >> is bitshift right; & is bitwise AND; 0xFF = 255 = all 8 bits set
        let r = Double((int >> 16) & 0xFF) / 255  // top 8 bits
        let g = Double((int >> 8) & 0xFF) / 255   // middle 8 bits
        let b = Double(int & 0xFF) / 255           // bottom 8 bits

        // Initialize Color with the RGB components
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview

/// SwiftUI Preview — shows the card in Xcode's Canvas without running the app.
///
/// WHAT IS #Preview?
/// It's a macro (introduced in Swift 5.9 / Xcode 15) that generates a preview
/// in Xcode's canvas. You can see your UI without launching the simulator.
/// It's like a live HTML preview but for Swift views.
#Preview {
    ScrollView {
        VStack(spacing: 0) {
            // Same-club double
            ResultCard(result: DoubleResult.preview_sameClub)
            // Cross-club double with gap
            ResultCard(result: DoubleResult.preview_crossClub)
        }
    }
    .background(Color.surfaceColor)
    .preferredColorScheme(.dark)
}

// MARK: - Preview Data

/// Sample data for Xcode previews and SwiftUI Canvas.
/// `.preview_*` properties are defined in an extension so they're easy to find
/// and don't pollute the main struct.
extension DoubleResult {
    static let preview_sameClub = DoubleResult(
        firstClubId: 102,
        firstClubName: "Flatiron",
        firstClubNbhd: "Flatiron & Nomad",
        firstClassName: "Barre",
        firstStart: 630,   // 10:30 AM
        firstEnd: 690,     // 11:30 AM
        firstInstructor: "Amanda K.",
        secondClubId: 102,
        secondClubName: "Flatiron",
        secondClubNbhd: "Flatiron & Nomad",
        secondClassName: "Sculpt",
        secondStart: 690,  // 11:30 AM (back-to-back)
        secondEnd: 750,
        secondInstructor: "Jessica L.",
        gapMinutes: 0,
        sameClub: true
    )

    static let preview_crossClub = DoubleResult(
        firstClubId: 102,
        firstClubName: "Flatiron",
        firstClubNbhd: "Flatiron & Nomad",
        firstClassName: "Barre",
        firstStart: 540,   // 9:00 AM
        firstEnd: 600,     // 10:00 AM
        firstInstructor: nil,
        secondClubId: 160,
        secondClubName: "Nomad",
        secondClubNbhd: "Flatiron & Nomad",
        secondClassName: "Arms & Abs",
        secondStart: 630,  // 10:30 AM (+30 min gap)
        secondEnd: 690,
        secondInstructor: "Chris B.",
        gapMinutes: 30,
        sameClub: false
    )
}
