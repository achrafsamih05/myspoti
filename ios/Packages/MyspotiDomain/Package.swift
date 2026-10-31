// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MyspotiDomain",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MyspotiDomain",
            targets: ["MyspotiDomain"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MyspotiDomain",
            dependencies: []
        ),
    ]
)

