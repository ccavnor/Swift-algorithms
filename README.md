# Swift Data Structures and Algorithms

A Swift package that implements various data structures (both imperative and functional) in the Swift programming language.

These were built mainly for self-knowledge and use in my own projects, but are freely shared under the MIT license
for use by others. I make no guarantees that these implementations are the fastest or most efficient algorithms out
there, but they are well documented, commented, and tested.

Further, they are built as a package in a SwiftPM project because they are tightly interrelated (where practical). 
For instance, both the Stack and Heap implementations use the LinkedList implementation.

To use this package in a SwiftPM project, you need to set it up as a package dependency:
```
// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "MyPackage",
  dependencies: [
    .package(
      url: "https://github.com/ccavnor/Swift-algorithms.git" 
    )
  ],
  targets: [
    .target(
      name: "MyTarget",
      dependencies: [
        .product(name: "Collections", package: "ccavnor-swift-collections")
      ]
    )
  ]
)
```

See individual target documents in this package via the following links:

## Immutable data structures for functional logic
- [Stack](https://ccavnor.github.io/Swift-algorithms/documentation/valuebasedstack/)
- [Binary Search Tree](https://ccavnor.github.io/Swift-algorithms/documentation/valuebasedbinarysearchtree/)

## Bags
- [LinkedList](https://ccavnor.github.io/Swift-algorithms/documentation/linkedlist/)
- [Stack](https://ccavnor.github.io/Swift-algorithms/documentation/stack/)
- [Heap](https://ccavnor.github.io/Swift-algorithms/documentation/heap/)

## Trie
- [Trie](https://ccavnor.github.io/Swift-algorithms/documentation/trie/)

## Binary Search Trees
- [Binary Search Tree](https://ccavnor.github.io/Swift-algorithms/documentation/binarysearchtree/)
- [Self balancing AVL Tree](https://ccavnor.github.io/Swift-algorithms/documentation/avltree/)
- [Interval Tree - a self balancing BST that uses Intervals as values](https://ccavnor.github.io/Swift-algorithms/documentation/intervaltree/)
- [Time Interval Tree - an Interval Tree that uses Date valued intervals](https://ccavnor.github.io/Swift-algorithms/documentation/timeintervaltree/)

> [!TIP]
> Other sources for Swift collections (data structures and algoritms) can be found here:
> [The Swift Algorithm Club](https://github.com/kodecocodes/swift-algorithm-club/tree/master)
> [Apple's Swift Collections ](https://github.com/apple/swift-collections)
