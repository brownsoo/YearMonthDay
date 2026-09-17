// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "YearMonthDay",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "YearMonthDay",
            targets: ["YearMonthDay"]),
    ],
    targets: [
        .target(name: "YearMonthDay"),
        .testTarget(
            name: "YearMonthDayTests",
            dependencies: ["YearMonthDay"]),
    ]
)
