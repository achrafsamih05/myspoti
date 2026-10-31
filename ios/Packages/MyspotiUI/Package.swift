// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MyspotiUI",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MyspotiUI",
            targets: ["MyspotiUI"]
        ),
    ],
    dependencies: [
        .package(path: "../MyspotiDomain")
    ],
    targets: [
        .target(
            name: "MyspotiUI",
            dependencies: [
                "MyspotiDomain"
            ]
        ),
    ]
)

