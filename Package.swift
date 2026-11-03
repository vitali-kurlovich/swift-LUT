// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-LUT",
    platforms: [
        .macOS(.v14),
        .iOS(.v16),
        .watchOS(.v10),
        .tvOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LUT",
            targets: ["LUT"]
        ),
        .executable(
            name: "lut-convert",
            targets: ["LUTConvert"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.27.0"),

    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LUT",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            ]

        ),
        .executableTarget(
            name: "LUTConvert",
            dependencies: ["LUT"]
        ),
        .testTarget(
            name: "LUTTests",
            dependencies: ["LUT"]

        ),
    ],
    swiftLanguageModes: [.v6]
)
