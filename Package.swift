// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
    name: "Algorithms",
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    products: [
        .library(name: "ValueBasedStack", targets: ["ValueBasedStack"]),
        .library(name: "ReferenceBasedBinarySearchTree",targets: ["BinarySearchTree"]),
        .library(name: "ValueBasedBinarySearchTree",targets: ["ValueBasedBinarySearchTree"]),
        .library(name: "IntervalTree", targets: ["IntervalTree"]),
        .library(name: "AVLTree", targets: ["AVLTree"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    targets: [
        // protocols
        .target(
            name: "TreeProtocol",
            dependencies: [],
            path: "Sources/Protocols/TreeProtocol"),
        // code
        .target(
            name: "ValueBasedStack",
            dependencies: []),
        .testTarget(
            name: "StackTests",
            dependencies: ["ValueBasedStack"]),
        .target(
            name: "BinarySearchTree",
            dependencies: ["TreeProtocol"],
            path: "Sources/ReferenceBasedBinarySearchTree"),
        .testTarget(
            name: "ReferenceBasedBinarySearchTreeTests",
            dependencies: ["BinarySearchTree"]),
        .target(
            name: "ValueBasedBinarySearchTree",
            dependencies: ["ValueBasedStack"]),
        .testTarget(
            name: "ValueBasedBinarySearchTreeTests",
            dependencies: ["ValueBasedStack","ValueBasedBinarySearchTree"]),
        .target(
            name: "AVLTree",
            dependencies: ["BinarySearchTree"]),
        .testTarget(
            name: "AVLTreeTests",
            dependencies: ["AVLTree"]),
        .target(
            name: "IntervalTree",
            dependencies: ["BinarySearchTree", "AVLTree"]),
        .testTarget(
            name: "IntervalTreeTests",
            dependencies: ["IntervalTree"]),
    ]
)



