// =============================================================================
// ResultCard.swift
// EQX Doubles — iOS App
// =============================================================================

import SwiftUI

// MARK: - Color Constants

extension Color {
    static let eqxLime = Color(hex: "#C8F23A")
    static let cardBackground = Color(hex: "#1A1A1A")
    static let cardBorder = Color(hex: "#2E2E2E")
    static let surfaceColor = Color(hex: "#111111")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#999999")
    static let textMuted = Color(hex: "#666666")
}

// MARK: - ResultCard

struct ResultCard: View {

    let result: DoubleResult

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Row
            headerRow

            // Transit Row
            transitRow

            // Divider
            Rectangle()
                .fill(Color.cardBorder)
                .frame(height: 1)

            // Class Cells
            classCellsStack
        }
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    // MARK: - Header Row

    private var headerRow: some View {
        HStack(alignment: .center) {
            Text(locationLabel)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.textPrimary)
                .lineLimit(1)
            Spacer()
            gapBadge
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - Transit Row

    private var transitRow: some View {
        let info = transitInfo(from: result.firstClubId, to: result.secondClubId, clubs: Club.allClubs)
        return HStack(spacing: 6) {
            Text(info.type.icon)
                .font(.system(size: 12))
            Text(info.label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }

    // MARK: - Location Label

    private var locationLabel: String {
        result.sameClub
            ? result.firstClubName
            : "\(result.firstClubName) → \(result.secondClubName)"
    }

    // MARK: - Gap Badge

    private var gapBadge: some View {
        Text(gapLabel)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(result.gapMinutes == 0 ? Color.black : Color.eqxLime)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                result.gapMinutes == 0
                    ? Color.eqxLime
                    : Color.eqxLime.opacity(0.12)
            )
            .cornerRadius(100)
            .overlay(
                Capsule()
                    .stroke(Color.eqxLime.opacity(result.gapMinutes == 0 ? 0 : 0.4), lineWidth: 1)
            )
    }

    private var gapLabel: String {
        result.gapMinutes == 0 ? "Back-to-back" : "+\(result.gapMinutes) min"
    }

    // MARK: - Class Cells (Stacked)

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

struct ClassCell: View {
    let clubName: String
    let className: String
    let start: Int
    let end: Int
    let instructor: String?
    let isFirst: Bool
    let sameClub: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(isFirst ? Color.eqxLime : Color.eqxLime.opacity(0.2))
                    .frame(width: 24, height: 24)
                Text(isFirst ? "1" : "2")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isFirst ? .black : .eqxLime)
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                Text(className)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)

                Text("\(fmt(start)) – \(fmt(end))")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(.eqxLime)

                if !sameClub {
                    Text(clubName)
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }

                if let name = instructor {
                    Text("with \(name)")
                        .font(.system(size: 12))
                        .foregroundColor(.textMuted)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 0) {
            ResultCard(result: DoubleResult.preview_sameClub)
            ResultCard(result: DoubleResult.preview_crossClub)
        }
    }
    .background(Color.surfaceColor)
    .preferredColorScheme(.dark)
}

// MARK: - Preview Data

extension DoubleResult {
    static let preview_sameClub = DoubleResult(
        firstClubId: 102,
        firstClubName: "Flatiron",
        firstClubNbhd: "Flatiron & Nomad",
        firstClassName: "Barre",
        firstStart: 630,
        firstEnd: 690,
        firstInstructor: "Amanda K.",
        secondClubId: 102,
        secondClubName: "Flatiron",
        secondClubNbhd: "Flatiron & Nomad",
        secondClassName: "Sculpt",
        secondStart: 690,
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
        firstStart: 540,
        firstEnd: 600,
        firstInstructor: nil,
        secondClubId: 160,
        secondClubName: "Nomad",
        secondClubNbhd: "Flatiron & Nomad",
        secondClassName: "Arms & Abs",
        secondStart: 630,
        secondEnd: 690,
        secondInstructor: "Chris B.",
        gapMinutes: 30,
        sameClub: false
    )
}
