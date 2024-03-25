// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
    name: "Algorithms",
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    products: [
        .library(name: "BinarySearchTree",targets: ["BinarySearchTree"]),
        .library(name: "LinkedList", targets: ["LinkedList"]),
        .library(name: "IntervalTree", targets: ["IntervalTree"]),
        .library(name: "TimeIntervalTree", targets: ["TimeIntervalTree"]),
        .library(name: "AVLTree", targets: ["AVLTree"]),
        .library(name: "Trie", targets: ["Trie"]),
        //.library(name: "RETE", targets: ["RETE"]),
        .library(name: "Queue", targets: ["Queue"]),
        .library(name: "Stack", targets: ["Stack"]),
        .library(name: "Heap", targets: ["Heap"]),
        // functional code
        .library(name: "ValueBasedStack", targets: ["ValueBasedStack"]),
        .library(name: "ValueBasedBinarySearchTree",targets: ["ValueBasedBinarySearchTree"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.

        // DateHelper for Date and Time manipulations
        .package(url: "https://github.com/melvitax/DateHelper.git", from: "5.0.0"),

        // BigNumber for precision Date difference calcs
        //.package(url: "https://github.com/mkrd/Swift-BigInt.git", .upToNextMajor(from: "2.2.0"))
        //.package(url: "https://github.com/mkrd/Swift-BigInt.git", branch: "master")

        // The DocC plugin that allows for GitHub README.md generation:
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),

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
        .target(
            name: "TrieProtocol",
            dependencies: [],
            path: "Sources/Protocols/TrieProtocol"),
        .target(
            name: "IteratableListProtocol",
            dependencies: [],
            path: "Sources/Protocols/IteratableListProtocol"),
        // code
        .target(
            name: "BinarySearchTree",
            dependencies: ["TreeProtocol"],
            path: "Sources/Trees/BST"),
        .testTarget(
            name: "BinarySearchTreeTests",
            dependencies: ["BinarySearchTree"]),
        .target(
            name: "AVLTree",
            dependencies: ["BinarySearchTree"],
            path: "Sources/Trees/AVLTree"),
        .testTarget(
            name: "AVLTreeTests",
            dependencies: ["AVLTree"]),
        .target(
            name: "IntervalTree",
            dependencies: ["BinarySearchTree", "AVLTree"],
            path: "Sources/Trees/IntervalTree"),
        .testTarget(
            name: "IntervalTreeTests",
            dependencies: ["IntervalTree"]),
        .target(
            name: "TimeIntervalTree",
            dependencies: ["IntervalTree"],
            path: "Sources/Trees/TimeIntervalTree"),
        .testTarget(
            name: "TimeIntervalTreeTests",
            dependencies: ["TimeIntervalTree", "DateHelper"]),
        .target(
            name: "LinkedList",
            dependencies: []),
        .testTarget(
            name: "LinkedListTests",
            dependencies: ["LinkedList"]),
        .target(
            name: "Trie",
            dependencies: ["TrieProtocol"]),
        .testTarget(
            name: "TrieTests",
            dependencies: ["Trie"]),
//        .target(
//            name: "RETE",
//            dependencies: []),
//        .testTarget(
//            name: "ReteTests",
//            dependencies: ["RETE"]),
        .target(
            name: "Queue",
            dependencies: ["IteratableListProtocol", "LinkedList"]),
        .testTarget(
            name: "QueueTests",
            dependencies: ["Queue"]),
        .target(
            name: "Stack",
            dependencies: ["IteratableListProtocol", "LinkedList"]),
        .testTarget(
            name: "StackTests",
            dependencies: ["Stack"]),
        .target(
            name: "Heap",
            dependencies: ["IteratableListProtocol"]),
        .testTarget(
            name: "HeapTests",
            dependencies: ["Heap"]),
        // code - functional implementations
        .target(
            name: "ValueBasedStack",
            dependencies: [],
            path: "Sources/Functional/Stack"),
        .testTarget(
            name: "ValueBasedStackTests",
            dependencies: ["ValueBasedStack"],
            path: "Tests/Functional/ValueBasedStackTests"),
        .target(
            name: "ValueBasedBinarySearchTree",
            dependencies: ["ValueBasedStack"],
            path: "Sources/Functional/Tree"),
        .testTarget(
            name: "ValueBasedBinarySearchTreeTests",
            dependencies: ["ValueBasedStack","ValueBasedBinarySearchTree"],
            path: "Tests/Functional/ValueBasedBinarySearchTreeTests")
    ]
)



