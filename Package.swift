// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Insomnia",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "Insomnia", targets: ["Insomnia"])],
    targets: [.executableTarget(name: "Insomnia", path: "Insomnia", exclude: ["Info.plist"])]
)
