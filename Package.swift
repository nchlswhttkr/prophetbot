// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Prophetbot",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .executable(name: "prophetbot-gpg", targets: ["ProphetbotGpg"]),
    .executable(name: "prophetbot-ssh", targets: ["ProphetbotSsh"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.8.2")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "ProphetbotCore",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
      resources: [
        .process("Resources/icon.png")
      ]
    ),

    .executableTarget(
      name: "ProphetbotGpg",
      dependencies: [
        "ProphetbotCore",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
    ),

    .executableTarget(
      name: "ProphetbotSsh",
      dependencies: [
        "ProphetbotCore",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
    ),
  ]
)
