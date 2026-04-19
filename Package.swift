// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "swift-nbt",
    products: [
        .library(name: "NBT", targets: ["NBT"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "NBT", dependencies: [
            // NOTE: this dependency should be a trait, but atm i can't figure it out without getting weird errors
            .product(name: "NIOCore", package: "swift-nio"),
        ]),
        .testTarget(name: "NBTTests", dependencies: ["NBT"])
    ]
)
