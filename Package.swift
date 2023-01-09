// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "TBXML",
    products: [
        .library(
            name: "TBXML",
            targets: ["TBXML"]
        )
    ],
    targets: [
        .target(
            name: "TBXML",
            path: "TBXML",
            publicHeadersPath: "."
        ),
    ]
)
