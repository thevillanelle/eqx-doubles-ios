// swift-tools-version: 5.9
//
// Package.swift — Swift Package Manager configuration
// ====================================================
//
// Swift has TWO ways to define a project:
//   1. .xcodeproj — an Xcode project file (for full iOS apps with simulators)
//   2. Package.swift — Swift Package Manager (SPM), for libraries + command-line tools
//
// This file lets you open the project in Xcode via:
//   File → Open → select this folder (not a .xcodeproj, just the folder)
//
// For a REAL iOS app with a simulator target, you'd create an Xcode project.
// See README.md → "How to open in Xcode" for step-by-step instructions.
//

import PackageDescription

let package = Package(
    name: "EQXDoubles",
    platforms: [
        // Minimum iOS version — iOS 17 supports all the SwiftUI features we use
        .iOS(.v17)
    ],
    targets: [
        .executableTarget(
            name: "EQXDoubles",
            path: "EQXDoubles",
            resources: [.process("Info.plist")]
        )
    ]
)
