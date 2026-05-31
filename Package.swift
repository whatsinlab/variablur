// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Variablur",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Variablur",
            targets: ["Variablur"]
        ),
    ],
    targets: [
        .target(
            name: "Variablur",
            plugins: [
                .plugin(name: "VariablurMetalPlugin"),
            ]
        ),
        .testTarget(
            name: "VariablurTests",
            dependencies: ["Variablur"]
        ),
        .executableTarget(
            name: "VariablurMetalCompiler"
        ),
        .plugin(
            name: "VariablurMetalPlugin",
            capability: .buildTool(),
            dependencies: ["VariablurMetalCompiler"]
        ),
    ]
)
