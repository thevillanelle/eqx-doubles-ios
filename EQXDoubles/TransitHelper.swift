import Foundation
import CoreLocation

// Transit type between two clubs
enum TransitType: String {
    case sameGym = "same"
    case walking = "walk"
    case quickTrain = "quick-train"
    case extended = "extended"
    
    var icon: String {
        switch self {
        case .sameGym: return "🏋"
        case .walking: return "🚶"
        case .quickTrain, .extended: return "🚇"
        }
    }
    
    var color: String { // hex
        switch self {
        case .sameGym: return "#4af0a0"
        case .walking: return "#C8F23A"
        case .quickTrain: return "#f0c94a"
        case .extended: return "#f0844a"
        }
    }
}

struct TransitInfo {
    let type: TransitType
    let label: String
    let minGapMinutes: Int
}

// Subway lines per club ID - matches the web app
let CLUB_LINES: [Int: [String]] = [
    110: ["2","3","4","5","J","Z"],
    128: ["A","C","E","2","3","4","5"],
    111: ["1","2","3","A","C","E"],
    122: ["B","D","F","M","J","Z"],
    114: ["N","R","Q","W","B","D","F","M"],
    135: ["B","D","F","M","6"],
    124: ["1"],
    162: ["1","C","E"],
    112: ["A","C","E","L","1","2","3"],
    116: ["C","E","1"],
    102: ["N","R","Q","W","F","M","6"],
    136: ["6","N","R"],
    160: ["N","R","Q","W","6"],
    138: ["7","A","C","E"],
    127: ["B","D","F","M","7"],
    108: ["4","5","6","7","S"],
    109: ["4","5","6","7","S"],
    126: ["B","D","F","M","N","R"],
    133: ["6","E","M"],
    106: ["6","E","M"],
    115: ["6"],
    139: ["6","N","R"],
    107: ["1","N","R","Q","W","C","E"],
    113: ["A","B","C","D","1"],
    132: ["N","R","Q","W","4","5","6"],
    105: ["F","Q","4","5","6"],
    117: ["6","Q"],
    104: ["1","B","C"],
    129: ["4","5","6"],
    131: ["N","R","Q","W","4","5","6"],
    121: ["1","2","3"],
    103: ["1","2","3","B","C"],
    130: ["2","3","4","5","R"],
    134: ["A","C","F"],
    161: ["J","M","Z","L"],
    137: ["J","M","Z","L"]
]

func haversineDistanceMiles(_ lat1: Double, _ lng1: Double, _ lat2: Double, _ lng2: Double) -> Double {
    let R = 3958.8
    let dLat = (lat2 - lat1) * .pi / 180
    let dLng = (lng2 - lng1) * .pi / 180
    let a = sin(dLat/2)*sin(dLat/2) + cos(lat1 * .pi/180)*cos(lat2 * .pi/180)*sin(dLng/2)*sin(dLng/2)
    return R * 2 * atan2(sqrt(a), sqrt(1-a))
}

func haversineDistanceKm(_ lat1: Double, _ lng1: Double, _ lat2: Double, _ lng2: Double) -> Double {
    return haversineDistanceMiles(lat1, lng1, lat2, lng2) * 1.60934
}

func walkMinutes(from a: Club, to b: Club) -> Int {
    if a.id == b.id { return 0 }
    let R = 6371000.0
    let dLat = (b.lat - a.lat) * .pi / 180
    let dLng = (b.lng - a.lng) * .pi / 180
    let s = sin(dLat/2)*sin(dLat/2) + cos(a.lat * .pi/180)*cos(b.lat * .pi/180)*sin(dLng/2)*sin(dLng/2)
    let dist = R * 2 * atan2(sqrt(s), sqrt(1-s))
    return Int((dist * 1.3 / 80).rounded())
}

func transitInfo(from aId: Int, to bId: Int, clubs: [Club]) -> TransitInfo {
    if aId == bId {
        return TransitInfo(type: .sameGym, label: "Same gym", minGapMinutes: 0)
    }
    guard let a = clubs.first(where: { $0.id == aId }),
          let b = clubs.first(where: { $0.id == bId }) else {
        return TransitInfo(type: .walking, label: "Walk", minGapMinutes: 15)
    }
    let walk = walkMinutes(from: a, to: b)
    if walk <= 15 {
        return TransitInfo(type: .walking, label: "\(walk) min walk", minGapMinutes: walk)
    }
    let distKm = haversineDistanceKm(a.lat, a.lng, b.lat, b.lng)
    let aLines = CLUB_LINES[aId] ?? []
    let bLines = CLUB_LINES[bId] ?? []
    let shared = aLines.filter { bLines.contains($0) }
    if !shared.isEmpty {
        let stops = max(1, Int((distKm / 0.5).rounded()))
        let mins = Int(ceil(Double(stops * 2 + 10) / 5.0) * 5)
        let line = shared[0]
        if distKm < 4 {
            return TransitInfo(type: .quickTrain, label: "\(line) · ~\(mins) min", minGapMinutes: max(20, mins))
        } else {
            return TransitInfo(type: .extended, label: "\(line) · ~\(mins) min", minGapMinutes: max(35, mins))
        }
    }
    let mins = Int(ceil((distKm * 5 + 15) / 5) * 5)
    return TransitInfo(type: .extended, label: "~\(mins) min", minGapMinutes: max(35, mins))
}