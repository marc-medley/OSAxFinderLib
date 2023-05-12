// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OSAxFinderLib",
    platforms: [
        // specify each minimum deployment requirement, 
        // otherwise the platform default minimum is used.
        .macOS(.v10_15), // Catalina 
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        Product.executable(
            name: "OSAxFinderTool",
            targets: ["OSAxFinderTool"]),
        Product.library(
            name: "OSAxFinderLib",
            type: .static,
            targets: ["OSAxFinderLib"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .executableTarget(
            name: "OSAxFinderTool",
            dependencies: ["OSAxFinderLib"]),
        .target(
            name: "OSAxFinderLib",
            dependencies: []),
        .testTarget(
            name: "OSAxFinderTests",
            dependencies: ["OSAxFinderLib"]),
    ],
    swiftLanguageVersions: [.v5]
)
