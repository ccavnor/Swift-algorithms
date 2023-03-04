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

        // The DocC plugin that allows for GitHub README.md generation:
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        
        // Documentation is generated via a shell script called scripts/docAll.sh.
        // NOTE: for now, multi-target doc generation is not supported:
        //    https://github.com/apple/swift-docc/issues/255
        // But I provided a shell script called scripts/docAll.sh that will build each target
        // and extract out the required directories into a common doc directory called "allDocs".
        // The only manual step to be done is to copy these directories into the corresponding
        // directories of a single target (you can build it using scripts/buildGithubPagesDocs.sh)

        // The documentation for each target is accessed via the following link
        // (NOTE the ./documentation/<target-name> subdir):
        //   https://<username>.github.io/<repository-name>/documentation/<target-name>

        // Following are resources that outline the doc generation and usage in GitHub Pages:
        //  - https://github.com/apple/swift-docc-plugin
        //  - https://rhonabwy.com/2022/01/28/hosting-your-swift-library-docs-on-github-pages/
        //  - https://www.jessesquires.com/blog/2022/04/22/docc-on-github-pages/
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



