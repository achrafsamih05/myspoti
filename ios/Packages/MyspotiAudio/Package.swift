// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MyspotiAudio",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MyspotiAudio",
            targets: ["MyspotiAudio"]
        ),
    ],
    dependencies: [
        .package(path: "../MyspotiDomain")
    ],
    targets: [
        .target(
            name: "MyspotiAudio",
            dependencies: [
                "MyspotiDomain"
            ]
        ),
    ]
)

