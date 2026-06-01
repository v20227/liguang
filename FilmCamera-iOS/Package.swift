// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "FilmCamera",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "FilmCamera",
            type: .dynamic,
            targets: ["FilmCamera"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FilmCamera",
            dependencies: [],
            resources: [
                .process("film-camera.html")
            ]
        )
    ]
)
