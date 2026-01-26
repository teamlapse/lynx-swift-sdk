// swift-tools-version: 5.9

import PackageDescription

// LynxJS XCFrameworks for iOS
// Built from CocoaPods sources using build-xcframeworks.sh

let package = Package(
    name: "LynxSwiftSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "Lynx", targets: ["Lynx"]),
        .library(name: "LynxBase", targets: ["LynxBase"]),
        .library(name: "LynxServiceAPI", targets: ["LynxServiceAPI"]),
        .library(name: "PrimJS", targets: ["PrimJS"]),
        .library(name: "LynxService", targets: ["LynxService"]),
        .library(name: "XElement", targets: ["XElement"]),
        .library(name: "LynxDevtool", targets: ["LynxDevtool"]),
        .library(name: "BaseDevtool", targets: ["BaseDevtool"]),
        .library(name: "DebugRouter", targets: ["DebugRouter"]),
        .library(name: "SocketRocket", targets: ["SocketRocket"]),
    ],
    targets: [
        .binaryTarget(name: "Lynx", path: "XCFrameworks/Lynx.xcframework"),
        .binaryTarget(name: "LynxBase", path: "XCFrameworks/LynxBase.xcframework"),
        .binaryTarget(name: "LynxServiceAPI", path: "XCFrameworks/LynxServiceAPI.xcframework"),
        .binaryTarget(name: "PrimJS", path: "XCFrameworks/PrimJS.xcframework"),
        .binaryTarget(name: "LynxService", path: "XCFrameworks/LynxService.xcframework"),
        .binaryTarget(name: "XElement", path: "XCFrameworks/XElement.xcframework"),
        .binaryTarget(name: "LynxDevtool", path: "XCFrameworks/LynxDevtool.xcframework"),
        .binaryTarget(name: "BaseDevtool", path: "XCFrameworks/BaseDevtool.xcframework"),
        .binaryTarget(name: "DebugRouter", path: "XCFrameworks/DebugRouter.xcframework"),
        .binaryTarget(name: "SocketRocket", path: "XCFrameworks/SocketRocket.xcframework"),
    ]
)
