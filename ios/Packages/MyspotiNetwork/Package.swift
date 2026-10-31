// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MyspotiNetwork",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MyspotiNetwork",
            targets: ["MyspotiNetwork"]
        ),
    ],
    dependencies: [
        .package(path: "../MyspotiDomain")
    ],
    targets: [
        .target(
            name: "MyspotiNetwork",
            dependencies: [
                "MyspotiDomain"
            ]
        ),
    ]
)

