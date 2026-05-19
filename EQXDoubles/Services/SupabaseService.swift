// =============================================================================
// SupabaseService.swift
// EQX Doubles — iOS App
// =============================================================================
//
// This file is the entire networking layer of the app.
// We call the Supabase REST API DIRECTLY using Apple's URLSession — no
// third-party SDK. This is intentional: it lets you see exactly how HTTP
// requests work under the hood.
//
// CONCEPTS EXPLAINED IN THIS FILE:
//
// ── WHAT IS URLSession? ───────────────────────────────────────────────────────
// URLSession is Apple's built-in HTTP networking framework. It's the iOS/macOS
// equivalent of Python's `requests` library or JavaScript's `fetch()`.
// You create a URLRequest (the "what to send"), then URLSession sends it over
// the network and gives you back the response data.
//
// ── WHAT IS async/await? ──────────────────────────────────────────────────────
// Network calls take time — usually 100ms to 2 seconds. You don't want your app
// to FREEZE while waiting. That's where async/await comes in.
//
// WITHOUT async/await (old style, using callbacks/closures):
//   URLSession.shared.dataTask(with: request) { data, response, error in
//       // This runs LATER, when the request finishes
//       processData(data)
//   }.resume()
//   // Code here runs IMMEDIATELY — data isn't ready yet!
//
// WITH async/await (modern Swift):
//   let (data, response) = try await URLSession.shared.data(for: request)
//   // This line PAUSES here until the network call finishes
//   // But it doesn't freeze the app — other things can still run
//   processData(data)  // Now data IS ready
//
// `async` = this function may pause and wait for something
// `await` = wait here until this async thing finishes
//
// ── WHAT IS `throws`? ─────────────────────────────────────────────────────────
// `throws` means "this function might fail and throw an Error."
// When you call a throwing function, you MUST use `try`:
//   let results = try await service.findDoubles(params: params)
//
// If the function throws, the error propagates UP the call stack until
// something catches it with a `do/catch` block (see SearchViewModel).
//
// ── WHAT IS JSONEncoder/JSONDecoder? ──────────────────────────────────────────
// JSONEncoder converts a Swift Codable struct → JSON bytes (Data)
// JSONDecoder converts JSON bytes (Data) → a Swift Codable struct
//
// Example:
//   struct Point: Codable { var x: Int; var y: Int }
//   let point = Point(x: 3, y: 7)
//   let data = try JSONEncoder().encode(point)   // → {"x":3,"y":7}
//   let back = try JSONDecoder().decode(Point.self, from: data)  // → Point(x:3,y:7)
//
// ── WHAT IS A CLASS vs STRUCT? ────────────────────────────────────────────────
// SupabaseService is a CLASS, not a struct. Why?
//
// Classes are REFERENCE TYPES:
//   var a = SupabaseService()
//   var b = a       // b and a point to the SAME object in memory
//   b.someValue = 5 // this changes a.someValue too!
//
// Structs are VALUE TYPES:
//   var a = SearchParams()
//   var b = a       // b is an independent COPY
//   b.cat1 = "yoga" // only b changes; a is unaffected
//
// We use a class here because we want ONE shared service object (singleton),
// and we want it to be reference-counted (ARC) rather than copied.
//
// ── WHAT IS A SINGLETON? ──────────────────────────────────────────────────────
// A singleton is one shared instance of a class used everywhere in the app.
// `static let shared = SupabaseService()` creates ONE instance at startup.
// Every part of the app that needs networking uses SupabaseService.shared —
// they all get the same object.
// =============================================================================

import Foundation

// MARK: - SupabaseService

/// Handles all communication with the Supabase backend.
///
/// Uses `final` to prevent subclassing (a performance hint to the compiler:
/// "there are no subclasses, optimize freely").
final class SupabaseService {

    // MARK: - Singleton

    // `static let shared` creates a single, lazily-initialized instance.
    // Thread-safe by default in Swift — guaranteed to be initialized once.
    static let shared = SupabaseService()

    // MARK: - Constants

    // These are our Supabase credentials.
    // `private` means only code inside this class can access them.
    // In a production app you'd load these from an environment file or
    // Apple's Secrets management — never hardcode credentials in shipping apps.
    private let supabaseURL = "https://hprkoonlydcjqxrgjwtr.supabase.co"
    private let anonKey = "sb_publishable_qHE_ZAyuekcsSDMpmK3a1w_fkWuo57M"

    // MARK: - Init

    // `private init()` prevents anyone from calling `SupabaseService()` directly.
    // The only way to get an instance is through `SupabaseService.shared`.
    private init() {}

    // MARK: - RPC Request Body

    /// The exact JSON structure the `find_doubles` RPC expects.
    /// Must be Encodable so JSONEncoder can turn it into JSON bytes.
    ///
    /// ALL fields must be present in the JSON body — the RPC won't work if any
    /// required parameter is missing.
    private struct FindDoublesBody: Encodable {
        let p_club_ids: [Int]
        let p_day: String
        let p_cat1: String
        let p_cat2: String
        let p_max_gap: Int
        let p_pair_order: String
        let p_win_start: Int
        let p_win_end: Int
    }

    // MARK: - Main API Method

    /// Calls the Supabase `find_doubles` stored procedure and returns results.
    ///
    /// - Parameter params: All search parameters from the user's form.
    /// - Returns: An array of DoubleResult objects (may be empty if no pairs found).
    /// - Throws: A NetworkError if something goes wrong (see below).
    ///
    /// HOW TO CALL THIS:
    ///   do {
    ///       let results = try await SupabaseService.shared.findDoubles(params: myParams)
    ///       print(results.count) // works here — results are ready
    ///   } catch {
    ///       print("Error: \(error)")
    ///   }
    func findDoubles(params: SearchParams) async throws -> [DoubleResult] {

        // ── Step 1: Build the URL ─────────────────────────────────────────────
        // Supabase RPC endpoints follow this pattern:
        //   POST /rest/v1/rpc/<function_name>
        //
        // `guard let` is Swift's "safe unwrap" — URL(string:) returns URL?
        // (optional, because the string might be malformed). If it IS nil,
        // the `else` block runs (we throw an error). If it's NOT nil, `url`
        // is bound to the valid URL for the rest of the scope.
        guard let url = URL(string: "\(supabaseURL)/rest/v1/rpc/find_doubles") else {
            throw NetworkError.invalidURL
        }

        // ── Step 2: Build the request body ───────────────────────────────────
        // Convert the user's search params into the JSON body the RPC expects.
        let body = FindDoublesBody(
            p_club_ids:   Array(params.selectedClubIds).sorted(), // Set → sorted Array
            p_day:        dayOfWeek(from: params.date),           // Date → "MONDAY"
            p_cat1:       params.cat1,
            p_cat2:       params.cat2,
            p_max_gap:    params.maxGap,
            p_pair_order: params.pairOrder,
            p_win_start:  params.winStart,
            p_win_end:    params.winEnd
        )

        // JSONEncoder converts our Swift struct into raw bytes (Data).
        // `try` is required because encoding CAN fail (e.g., if a value
        // contains infinity or NaN, which JSON can't represent).
        let bodyData = try JSONEncoder().encode(body)

        // ── Step 3: Build the URLRequest ─────────────────────────────────────
        // A URLRequest wraps:
        //   • the URL
        //   • the HTTP method (GET, POST, etc.)
        //   • the headers (metadata about the request)
        //   • the body (the data you're sending)
        //
        // `var` because we need to mutate it (add headers, set method, set body).
        var request = URLRequest(url: url)

        // HTTP method: POST (we're sending data, not just reading)
        request.httpMethod = "POST"

        // HTTP headers — these tell the server how to interpret our request:
        //   apikey           → identifies our Supabase project
        //   Authorization    → proves we're allowed to call this API
        //   Content-Type     → tells the server the body is JSON
        //   Accept           → tells the server we want JSON back
        //   Prefer           → tells PostgREST (Supabase's query engine) to
        //                      return the result as a plain JSON array
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("params=single-object", forHTTPHeaderField: "Prefer")

        // Attach the JSON body to the request
        request.httpBody = bodyData

        // ── Step 4: Send the request ─────────────────────────────────────────
        // `URLSession.shared.data(for:)` is an async function.
        // `await` pauses THIS function here — the thread is freed to do other
        // work — and resumes when the network response comes back.
        //
        // It returns a tuple: (data: Data, response: URLResponse)
        //   data     = the raw bytes of the HTTP response body
        //   response = metadata about the response (status code, headers, etc.)
        let (data, response) = try await URLSession.shared.data(for: request)

        // ── Step 5: Check the HTTP status code ───────────────────────────────
        // The response is URLResponse. We cast it to HTTPURLResponse (a subclass)
        // to get the statusCode property. `as?` is a safe cast that returns nil
        // if the cast fails (which shouldn't happen for HTTP requests, but Swift
        // requires us to handle it).
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        // HTTP 200 = success. 4xx = client error. 5xx = server error.
        // 200...299 is a Swift range literal — matches any code from 200 to 299.
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to include the error body in the message for debugging
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, body: errorBody)
        }

        // ── Step 6: Decode the response ──────────────────────────────────────
        // The response is a JSON array like:
        //   [{"first_club_id": 102, "first_club_name": "Flatiron", ...}, ...]
        //
        // JSONDecoder reads the raw bytes and produces [DoubleResult].
        // `[DoubleResult].self` is Swift's way of passing a TYPE as an argument —
        // it tells the decoder "decode this data as an array of DoubleResult".
        let decoder = JSONDecoder()
        let results = try decoder.decode([DoubleResult].self, from: data)

        return results
    }

    // MARK: - Helper: Day of Week

    /// Extracts the weekday from a Date and returns it as an uppercase string.
    ///
    /// - Parameter date: Any Swift Date
    /// - Returns: One of: "SUNDAY", "MONDAY", "TUESDAY", ..., "SATURDAY"
    ///
    /// WHAT IS `private`?
    /// `private` means this function can ONLY be called from within this class.
    /// It's an implementation detail — callers don't need to know it exists.
    ///
    /// WHAT IS Calendar?
    /// Calendar is Apple's type for date math and locale-aware date operations.
    /// Calendar.current uses the device's current calendar (Gregorian, Hebrew, etc.)
    private func dayOfWeek(from date: Date) -> String {
        // Calendar.current is the user's current calendar (respects locale)
        let calendar = Calendar.current

        // component(_:from:) extracts one piece of a date.
        // .weekday returns 1 (Sunday) through 7 (Saturday) in the Gregorian calendar.
        let weekday = calendar.component(.weekday, from: date)

        // Map the integer to the uppercase string the RPC expects.
        // This array uses 1-based indexing: weekday=1 → index 1 = "SUNDAY"
        let days = ["", "SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]

        // Safely access the array. If weekday is somehow out of range, default to MONDAY.
        return days[safe: weekday] ?? "MONDAY"
    }
}

// MARK: - NetworkError

/// All the ways a network call can fail.
///
/// WHAT IS AN ENUM WITH ASSOCIATED VALUES?
/// Swift enums can carry extra data. `case httpError(statusCode: Int, body: String)`
/// is like a small struct bundled into an enum case. You pattern-match it:
///
///   switch error {
///   case .httpError(let code, let body):
///       print("HTTP \(code): \(body)")
///   case .invalidURL:
///       print("Bad URL")
///   }
///
/// Conforming to `Error` (a protocol) lets us `throw` these values.
/// Conforming to `LocalizedError` lets us provide a human-readable description
/// that appears in the UI via error.localizedDescription.
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, body: String)
    case decodingError(String)

    // `errorDescription` is the property LocalizedError requires.
    // It's computed — each case returns a different string.
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL — this is a bug, please report it."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .httpError(let code, let body):
            return "HTTP \(code): \(body)"
        case .decodingError(let msg):
            return "Couldn't parse the response: \(msg)"
        }
    }
}

// MARK: - Safe Array Subscript

/// Extends Array with a safe subscript that returns nil instead of crashing
/// when you access an out-of-bounds index.
///
/// Built-in Swift behavior: myArray[99] crashes if 99 >= myArray.count
/// With this extension: myArray[safe: 99] returns nil
///
/// WHAT IS A SUBSCRIPT?
/// A subscript lets you use [] notation on a type. Arrays have a built-in
/// subscript. We're adding a second one with an external label `safe:`.
extension Array {
    subscript(safe index: Int) -> Element? {
        // Check bounds before accessing
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}
