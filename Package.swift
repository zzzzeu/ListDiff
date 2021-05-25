// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ListDiff",
    products: [
        .library(
            name: "ListDiff",
            targets: ["ListDiff"]),
    ],
    dependencies: [
        .package(name: "Benchmark", url: "https://github.com/google/swift-benchmark", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "ListDiff",
            dependencies: []),
        .target(
            name: "ListDiffBenchmark",
            dependencies: ["ListDiff", "Benchmark"],
            path: "Benchmarks"),
    ]
)
