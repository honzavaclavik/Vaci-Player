// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VaciPlayer",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "VaciPlayer",
            targets: ["VaciPlayer"])
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "VaciPlayer",
            dependencies: []),
        .testTarget(
            name: "VaciPlayerTests",
            dependencies: ["VaciPlayer"])
    ]
)