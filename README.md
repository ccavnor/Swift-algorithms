# Swift Data Structures and Algorithms

## Overview
A Swift package that implements various data structures (both imperative and functional) in the Swift programming language.

These were built mainly for self-knowledge and use in my own projects, but are freely shared under the MIT license
for use by others. I make no guarantees that these implementations are the fastest or most efficient algorithms out
there, but they are well documented, commented, and tested.

Further, they are built as a package in a SwiftPM project because they are tightly interrelated (where practical). 
For instance, both the Stack and Heap implementations use the LinkedList implementation.

## Usage as a Swift Package
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

## Collection Documentation
The generated documentation for all collections in this package are linked below:

### Immutable data structures for functional logic
These are value based collections specifically implemented for functional applications. 

- [Stack](https://ccavnor.github.io/Swift-algorithms/documentation/valuebasedstack/)
- [Binary Search Tree](https://ccavnor.github.io/Swift-algorithms/documentation/valuebasedbinarysearchtree/)

### Bags
Bags are data structures that manipulate unsequenced data and allow for redundant values (unlike sets).

- [LinkedList](https://ccavnor.github.io/Swift-algorithms/documentation/linkedlist/)
- [Stack](https://ccavnor.github.io/Swift-algorithms/documentation/stack/)
- [Heap](https://ccavnor.github.io/Swift-algorithms/documentation/heap/)

### Trie
A k-ary search tree, a tree data structure used for locating specific keys. Tries are often used for pattern
matching of strings. Using a Trie, the key can be searched in O(l) time, where l is the length of the longest string. 

- [Trie](https://ccavnor.github.io/Swift-algorithms/documentation/trie/)

### Binary Search Trees
A Binary Search Tree (BST) is a data structure used to store and access keys in a sorted manner, giving it O(log n)
bounded search time when sorted. BSTs are restricted to set data, meaning that redundant keys/values are not allowed.

An implementation of the basic BST:

- [Binary Search Tree](https://ccavnor.github.io/Swift-algorithms/documentation/binarysearchtree/)

One major drawback of the BST is that it only guarantees O(log n) search time if it is sorted. However, the
act of sorting can take up to O(n) time to complete. The AVL tree is a self-sorting BST. By sorting itself,
it achieves O(log n) lookup, insertion and deletion costs in the average and worst cases: 

- [AVL Tree](https://ccavnor.github.io/Swift-algorithms/documentation/avltree/)

A self balancing BST that uses Intervals as keys

- [Interval Tree](https://ccavnor.github.io/Swift-algorithms/documentation/intervaltree/)

An Interval Tree that uses Date-valued intervals

- [Time Interval Tree](https://ccavnor.github.io/Swift-algorithms/documentation/timeintervaltree/)

> [!TIP]
> Other sources for Swift collections (data structures and algoritms) can be found here:
> - [The Swift Algorithm Club](https://github.com/kodecocodes/swift-algorithm-club/tree/master)
> - [Apple's Swift Collections ](https://github.com/apple/swift-collections)
