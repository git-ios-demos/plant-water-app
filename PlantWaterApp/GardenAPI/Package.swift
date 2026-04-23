// swiftlint:disable all
// swift-tools-version:6.1

import PackageDescription

let package = Package(
  name: "GardenAPI",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .watchOS(.v8),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "GardenAPI", targets: ["GardenAPI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apollographql/apollo-ios", exact: "2.1.0"),
  ],
  targets: [
    .target(
      name: "GardenAPI",
      dependencies: [
        .product(name: "ApolloAPI", package: "apollo-ios"),
      ],
      path: "./Sources"
    ),
  ],
  swiftLanguageModes: [.v6, .v5]
)
// swiftlint:enable all
