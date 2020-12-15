// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Gigya",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Gigya",
            targets: ["Gigya"]),
        .library(
            name: "GigyaTfa",
            targets: ["GigyaTfa"]),
        .library(
            name: "GigyaAuth",
            targets: ["GigyaAuth"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Gigya",
            dependencies: [],
            path: "GigyaSwift",
            exclude: ["Info.plist", "README.md", "Config.xcconfig"]),
        .target(
            name: "GigyaTfa",
            dependencies: ["Gigya"],
            path: "GigyaTfa",
            exclude: ["GigyaTfa/Info.plist", "README.md"]),
        .target(
            name: "GigyaAuth",
            dependencies: ["Gigya"],
            path: "GigyaAuth",
            exclude: ["GigyaAuth/Info.plist", "README.md"]),
    ]
)
