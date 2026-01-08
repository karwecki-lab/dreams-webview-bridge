// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DreamsWebViewApp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "DreamsWebViewApp",
            targets: ["DreamsWebViewApp"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/getdreams/dreams-ios-sdk", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "DreamsWebViewApp",
            dependencies: [
                .product(name: "DreamsKit", package: "dreams-ios-sdk")
            ]
        )
    ]
)
