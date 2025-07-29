// swift-tools-version: 5.9
@preconcurrency import PackageDescription

let package = Package(
  name: "Bitnagil",
  dependencies: [
    .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.0.0"),
    .package(url: "https://github.com/kakao/kakao-ios-sdk", from: "2.23.0"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0")
  ]
)
