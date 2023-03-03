//
//  ValueBasedBinarySearchTreeTests.swift
//  
//
//  Created by Christopher Charles Cavnor on 4/28/22.
//

import XCTest
import ValueBasedStack
@testable import ValueBasedBinarySearchTree


class ValueBasedBinarySearchTreeTest: XCTestCase {
    // creates tree of shape: (5  <- 8 -> (.  <- 10 -> 15))
    // where root is 8; nodes are 8, 10; and leafs are 5, 15
    func makeTree() -> ValueBasedBinarySearchTree<Int> {
        var tree = ValueBasedBinarySearchTree.leaf(8)
        tree = tree.insert(5)
        tree = tree.insert(10)
        tree = tree.insert(15)
        return tree
    }

    // From: https://thoughtbot.com/blog/introduction-to-function-currying-in-swift
    // Generic curry func where A, B, C might be different types, but are set by f.
    func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
        // type inference allows us to not have to bind generic type.
        return { a in { b in f(a, b) } }
    }

    func add(_ a: Int, _ b: Int) -> Int {
      return (a + b)
    }

    func test_curry() {
        let curriedAdd = curry(add)
        print(">>>", curriedAdd(1))
        print(">>>", curriedAdd(1)(2))
        let add1 = curriedAdd(1)
        let add2 = add1(2)
        print(">>>", add2)
        let xs = 1...10
        let xss = xs.map(add1) // [3, 4, 5, 6, etc]
        print(">>>", xss)
    }

    func test_init_from() {
        var tree = ValueBasedBinarySearchTree.init(from: [1])
        XCTAssertEqual(tree.root, 1)
        tree = ValueBasedBinarySearchTree.init(from: [1,2])
        XCTAssertEqual(tree.root, 1)
        tree = ValueBasedBinarySearchTree.init(from: [1,2,3])
        XCTAssertEqual(tree.root, 2)
        tree = ValueBasedBinarySearchTree.init(from: [1,2,3,4,5,6,7,8,9,10,11,12,13])
        XCTAssertEqual(tree.root, 7)
        tree = ValueBasedBinarySearchTree.init(from: [1,2,3,4,5,6,7,8,9,10,11,12,13].shuffled())
        XCTAssertEqual(tree.root, 7)
    }

    func test_count() {
        var tree = ValueBasedBinarySearchTree<Int>()
        tree = tree.insert(10)
        var nodeL = ValueBasedBinarySearchTree<Int>()
        var nodeR = ValueBasedBinarySearchTree<Int>()

        nodeL = nodeL.insert(5)
        nodeL = nodeL.insert(7)
        print(">>> \(nodeL)")
        XCTAssertEqual(nodeL.count, 2, "empty nodes are not counted")

        nodeR = nodeR.insert(11)
        nodeR = nodeR.insert(12)
        print(">>> \(nodeR)")
        XCTAssertEqual(nodeR.count, 2, "empty nodes are not counted")

        tree = tree.insert(nodeL)
        tree = tree.insert(nodeR)
        print(">>> \(tree)")
        XCTAssertEqual(tree.count, 5, "empty nodes are not counted")
    }

    func test_isLeaf() {
        var tree = makeTree()
        XCTAssertFalse(tree.isLeaf, "root is not leaf")
        tree = tree.search(value: 10)!
        XCTAssertFalse(tree.isLeaf, "10 has one child")
        tree = tree.search(value: 15)!
        XCTAssertTrue(tree.isLeaf, "15 is leaf of 10")
    }

    // test hasLeftChild, hasRightChild, hasAnyChild, hasBothChildren
    func test_hasChild() {
        var tree = makeTree()
        XCTAssertTrue(tree.hasAnyChild, "root has both children")
        XCTAssertTrue(tree.hasBothChildren, "root has both children")
        XCTAssertTrue(tree.hasLeftChild, "root has both children")
        XCTAssertTrue(tree.hasRightChild, "root has both children")
        tree = tree.search(value: 10)!
        print(">>> \(tree)")
        XCTAssertTrue(tree.hasAnyChild, "10 has right leaf and left empty")
        XCTAssertFalse(tree.hasBothChildren, "10 has right leaf and left empty")
        XCTAssertFalse(tree.hasLeftChild, "10 has right leaf and left empty")
        XCTAssertTrue(tree.hasRightChild, "10 has right leaf and left empty")
        tree = tree.search(value: 15)!
        XCTAssertFalse(tree.hasAnyChild, "15 is leaf of 10")
        XCTAssertFalse(tree.hasBothChildren, "15 is leaf of 10")
        XCTAssertFalse(tree.hasLeftChild, "15 is leaf of 10")
        XCTAssertFalse(tree.hasRightChild, "15 is leaf of 10")
    }

    // test isLeftChild, isRightChild
    func test_isChild() {
        let tree = ValueBasedBinarySearchTree(from: [8, 5, 10, 3, 12, 9, 6, 16])
        print(">>> \(tree)")
        // root
        XCTAssertFalse(tree.isLeftChild(8))
        XCTAssertFalse(tree.isRightChild(8))
        // parents
        XCTAssertTrue(tree.isLeftChild(5))
        XCTAssertFalse(tree.isRightChild(5))
        XCTAssertFalse(tree.isLeftChild(10))
        XCTAssertTrue(tree.isRightChild(10))
        XCTAssertFalse(tree.isLeftChild(nil))
        XCTAssertFalse(tree.isRightChild(nil))
        let node5 = tree.search(value: 5)!
        XCTAssertTrue(node5.isLeftChild(3))
        XCTAssertFalse(node5.isRightChild(3))
        XCTAssertTrue(node5.isRightChild(6))
        XCTAssertFalse(node5.isRightChild(3))
        XCTAssertFalse(node5.isLeftChild(nil))
        XCTAssertFalse(node5.isRightChild(nil))
        let node10 = tree.search(value: 10)!
        XCTAssertTrue(node10.isLeftChild(9))
        XCTAssertFalse(node10.isRightChild(9))
        XCTAssertTrue(node10.isRightChild(12))
        XCTAssertFalse(node10.isLeftChild(12))
        XCTAssertFalse(node10.isLeftChild(nil))
        XCTAssertFalse(node10.isRightChild(nil))
        let node12 = tree.search(value: 12)!
        XCTAssertTrue(node12.isLeftChild(nil))
        XCTAssertFalse(node12.isRightChild(nil))
        XCTAssertTrue(node12.isRightChild(16))
        XCTAssertFalse(node12.isLeftChild(16))
    }

    // tree is balanced when left and right sides are at most one level height difference
    func test_isBalanced() {
        var tree = makeTree()
        print(">>> \(tree)")
        XCTAssertTrue(tree.isBalanced())
        XCTAssertEqual(tree.left?.height, 0)
        XCTAssertEqual(tree.right?.height, 1)
        tree = tree.insert(5)
        print(">>> \(tree)")
        XCTAssertTrue(tree.isBalanced())
        XCTAssertEqual(tree.left?.height, tree.right?.height)
        tree = tree.insert(5)
        print(">>> \(tree)")
        XCTAssertTrue(tree.isBalanced())
        XCTAssertEqual(tree.left?.height, 2)
        XCTAssertEqual(tree.right?.height, 1)
        tree = tree.insert(5)
        print(">>> \(tree)")
        XCTAssertFalse(tree.isBalanced(), "tree is more than one level asymmetrical")
        XCTAssertEqual(tree.left?.height, 3)
        XCTAssertEqual(tree.right?.height, 1)
    }

    func test_median() {
        let tree = makeTree()
        XCTAssertEqual(tree.median([5]), 5)
        XCTAssertEqual(tree.median([4,5]), 4)
        XCTAssertEqual(tree.median([1,2,3]), 2)
        XCTAssertEqual(tree.median([1,2,3,4,5,6,7,8,9,10,11,12]), 6, "even number of elements")
        XCTAssertEqual(tree.median([1,2,3,4,5,6,7,8,9,10,11,12].shuffled()), 6, "even number of elements")
        XCTAssertEqual(tree.median([1,2,3,4,5,6,7,8,9,10,11,12,13]), 7, "odd number of elements")
        XCTAssertEqual(tree.median([1,2,3,4,5,6,7,8,9,10,11,12,13].shuffled()), 7, "odd number of elements")
    }

    func test_traverseInOrder() {
        let tree = makeTree()
        print(">>> \(tree)")
        var collect: [Int] = [Int]()
        tree.traverseInOrder(process: { collect.append($0) } )
        print(">>> \(collect)")
        XCTAssertEqual([5, 8, 10, 15], collect)
    }

    func test_traversePreOrder() {
        let tree = makeTree()
        print(">>> \(tree)")
        var collect: [Int] = [Int]()
        tree.traversePreOrder(process: { collect.append($0) } )
        print(">>> \(collect)")
        XCTAssertEqual([8, 5, 10, 15], collect)
    }

    func test_traversePostOrder() {
        let tree = makeTree()
        print(">>> \(tree)")
        var collect: [Int] = [Int]()
        tree.traversePostOrder(process: { collect.append($0) } )
        print(">>> \(collect)")
        XCTAssertEqual([5, 10, 15, 8], collect)
    }

    func test_root() {
        var tree = ValueBasedBinarySearchTree<Int>.init()
        XCTAssertEqual(tree.root, nil)
        tree = makeTree()
        XCTAssertEqual(tree.root, 8)
    }

    func test_isRoot() {
        let tree = makeTree()
        XCTAssertEqual(tree.isRoot(99), false, "value doesn't exist in tree")
        XCTAssertEqual(tree.isRoot(10), false, "not the root")
        XCTAssertEqual(tree.isRoot(8), true, "root of tree")
    }

    func test_height() {
        // test with empty tree
        var tree = ValueBasedBinarySearchTree<Int>.init()
        XCTAssertEqual(tree.height, 0)
        // test with only root
        tree = tree.insert(5)
        XCTAssertEqual(tree.height, 0)
        // test with full tree
        tree = ValueBasedBinarySearchTree(from: [8, 5, 10, 3, 12, 9, 6, 16])
        XCTAssertEqual(tree.left?.height, 1, "left branch without tree root node")
        XCTAssertEqual(tree.right?.height, 2, "right branch without tree root node")
        XCTAssertEqual(tree.height, 3, "longeset branch plus tree root node")
    }

    func test_depth() {
        var tree = ValueBasedBinarySearchTree<Int>.init()
        // test with only root
        tree = tree.insert(5)
        XCTAssertEqual(tree.depth(of: 5), 0)
        // test with full tree
        tree = ValueBasedBinarySearchTree(from: [8, 5, 10, 3, 12, 9, 6, 16])

        // root
        XCTAssertEqual(tree.depth(of: 8), 0, "root of tree")
        // leaves
        XCTAssertEqual(tree.depth(of: 3), 2)
        XCTAssertEqual(tree.depth(of: 6), 2)
        XCTAssertEqual(tree.depth(of: 9), 2)
        XCTAssertEqual(tree.depth(of: 16), 3)

        // parents
        XCTAssertEqual(tree.depth(of: 12), 2)
        XCTAssertEqual(tree.depth(of: 10), 1)
        XCTAssertEqual(tree.depth(of: 5), 1)
    }

    func test_search() {
        // test with empty tree
        var tree = ValueBasedBinarySearchTree<Int>.init()
        XCTAssertEqual(tree.search(value: 0), nil)
        // test with only root
        tree = tree.insert(5)
        var result = tree.search(value: 5)
        XCTAssertEqual(result?.count, 1)
        // test with full tree
        tree = ValueBasedBinarySearchTree(from: [8, 5, 10, 3, 12, 9, 6, 16])
        XCTAssertEqual(tree.height, tree.search(value: tree.root!)?.height, "height of tree is equal to distance from root to lowest leaf")
        result = tree.search(value: 16)
        XCTAssertEqual(result?.height, 0, "16 is a leaf node")
        result = tree.search(value: 12)
        XCTAssertEqual(result?.height, 1, "12 is one node from leaf")
        // test values not in tree
        result = tree.search(value: 99)
        XCTAssertEqual(result, nil, "value is not in tree")
        // test tree with duplicate node values
        tree = ValueBasedBinarySearchTree(from: [8, 5, 10])
        result = tree.search(value: 5)
        XCTAssertEqual(result?.height, 0)
        tree = tree.insert(5)
        tree = tree.insert(5)
        result = tree.search(value: 5)
        XCTAssertEqual(result?.height, 2, "search returns last found value")
    }

    func test_min() {
        // test with empty tree
        var tree = ValueBasedBinarySearchTree<Int>()
        XCTAssertEqual(tree.minimum, nil)
        // test with only root
        tree = tree.insert(5)
        XCTAssertEqual(tree.minimum, 5)
        tree = ValueBasedBinarySearchTree(from: [8, 5, 10, 3, 12, 9, 6, 16])
        XCTAssertEqual(tree.minimum, 3)
    }

    func test_max() {
        // test with empty tree
        var tree = ValueBasedBinarySearchTree<Int>()
        XCTAssertEqual(tree.maximum, nil)
        // test with only root
        tree = tree.insert(5)
        XCTAssertEqual(tree.maximum, 5)
        tree = ValueBasedBinarySearchTree(from: [8, 5, 10, 3, 12, 9, 6, 16])
        XCTAssertEqual(tree.maximum, 16)
    }

    func test_left() {
        // test with empty tree
        var tree = ValueBasedBinarySearchTree<Int>()
        XCTAssertEqual(tree.left?.value, nil)
        // test with only root
        tree = ValueBasedBinarySearchTree.leaf(50)
        XCTAssertEqual(tree.left?.value, nil)
        tree = makeTree()
        XCTAssertEqual(tree.left?.value, 5, "left branch of tree")
    }

    func test_right() {
        // test with empty tree
        var tree = ValueBasedBinarySearchTree<Int>()
        XCTAssertEqual(tree.right?.value, nil)
        // test with only root
        tree = ValueBasedBinarySearchTree.leaf(50)
        XCTAssertEqual(tree.right?.value, nil)
        // test with test tree
        tree = makeTree()
        let match = ValueBasedBinarySearchTree.node(ValueBasedBinarySearchTree<_>.empty, 10, ValueBasedBinarySearchTree<_>.leaf(15))
        XCTAssertEqual(tree.right, match, "right branch of tree")
    }

    func test_parents() {
        var tree = ValueBasedBinarySearchTree(from: [8, 5, 10, 3, 12, 9, 6, 16])
        print(">>> \(tree)")
        var accum = ValueBasedStack<Int>()
        // root
        tree.parents(of: 8, using: { accum = accum.push($0) } )
        XCTAssertEqual(accum.toArray, [], "root has no parent")
        // leaves
        accum = ValueBasedStack<Int>()
        tree.parents(of: 3, using: { accum = accum.push($0) })
        XCTAssertEqual(accum.toArray, [8,5], "parents of 3")

        accum = ValueBasedStack<Int>()
        tree.parents(of: 6, using: { accum = accum.push($0) })
        XCTAssertEqual(accum.toArray, [8,5], "parents of 6")

        accum = ValueBasedStack<Int>()
        tree.parents(of: 9, using: { accum = accum.push($0) })
        XCTAssertEqual(accum.toArray, [8,10], "parents of 9")

        accum = ValueBasedStack<Int>()
        tree.parents(of: 16, using: { accum = accum.push($0) })
        XCTAssertEqual(accum.toArray, [8,10,12], "parents of 16")

        // parents
        accum = ValueBasedStack<Int>()
        tree.parents(of: 12, using: { accum = accum.push($0) })
        XCTAssertEqual(accum.toArray, [8,10], "parents of 12")

        accum = ValueBasedStack<Int>()
        tree.parents(of: 10, using: { accum = accum.push($0) })
        XCTAssertEqual(accum.toArray, [8], "parents of 10")

        accum = ValueBasedStack<Int>()
        tree.parents(of: 5, using: { accum = accum.push($0) })
        XCTAssertEqual(accum.toArray, [8], "parents of 5")

        // test with tree that has duplicate values: only top level match is returned
        tree = ValueBasedBinarySearchTree(from: [8, 5, 10])

        accum = ValueBasedStack<Int>()
        tree.parents(of: 5, using: { accum = accum.push($0) })
        XCTAssertEqual(accum.toArray, [8], "parents of 5")

        tree = tree.insert(5)
        accum = ValueBasedStack<Int>()
        tree.parents(of: 5, using: { accum = accum.push($0) })
        XCTAssertEqual(accum.toArray, [8], "parents of 5")
    }

    func test_parent_of() {
        // test with empty tree
        var tree = ValueBasedBinarySearchTree<Int>()
        tree = tree.insert(8)
        tree = tree.insert(5)
        tree = tree.insert(10)
        tree = tree.insert(3)
        tree = tree.insert(6)
        tree = tree.insert(9)
        tree = tree.insert(12)
        tree = tree.insert(7)
        tree = tree.insert(13)

        print(">>> \(tree)")
        // root
        XCTAssertEqual(tree.parent(of: 8), nil, "root has no parent")
        // leaves
        XCTAssertEqual(tree.parent(of: 3)?.value, 5)
        XCTAssertEqual(tree.parent(of: 7)?.value, 6)
        XCTAssertEqual(tree.parent(of: 9)?.value, 10)
        XCTAssertEqual(tree.parent(of: 13)?.value, 12)
        // parents
        XCTAssertEqual(tree.parent(of: 6)?.value, 5)
        XCTAssertEqual(tree.parent(of: 12)?.value, 10)
        XCTAssertEqual(tree.parent(of: 10)?.value, 8)
        XCTAssertEqual(tree.parent(of: 5)?.value, 8)
    }


    func testCreateFromArray() {
        let tree = ValueBasedBinarySearchTree(from: [8, 5, 10, 3, 12, 9, 6, 16])
        XCTAssertEqual(tree.count, 8)
        XCTAssertEqual(tree.toArray(), [3, 5, 6, 8, 9, 10, 12, 16])

        XCTAssertEqual(tree.search(value: 9)!.value, 9)
        XCTAssertNil(tree.search(value: 99))

        XCTAssertEqual(tree.minimum, 3)
        XCTAssertEqual(tree.maximum, 16)

        XCTAssertEqual(tree.height, 3)
        //XCTAssertEqual(tree.depth(), 0)

        let node1 = tree.search(value: 16)
        XCTAssertNotNil(node1)
        XCTAssertEqual(node1!.height, 0)
        //XCTAssertEqual(node1!.depth(), 3)

        let node2 = tree.search(value: 12)
        XCTAssertNotNil(node2)
        XCTAssertEqual(node2!.height, 1)
        //XCTAssertEqual(node2!.depth(), 2)

        let node3 = tree.search(value: 10)
        XCTAssertNotNil(node3)
        XCTAssertEqual(node3!.height, 2)
        //XCTAssertEqual(node3!.depth(), 1)
    }

    func test_insert_duplicates() {
        var tree = ValueBasedBinarySearchTree(from: [8, 5, 10])
        tree = tree.insert(8)
        tree = tree.insert(5)
        tree = tree.insert(10)
        XCTAssertEqual(tree.count, 6)
        XCTAssertEqual(tree.toArray(), [5, 5, 8, 8, 10, 10])
    }

    func test_remove_by_leaf() {
        var tree = ValueBasedBinarySearchTree(from: [1])
        tree = tree.remove(tree.root!)
        XCTAssertEqual(tree.count, 0)
        // remove leafs
        tree = makeTree()
        print(">>> \(tree)")
        XCTAssertEqual(tree.toArray(), [5,8,10,15])
        XCTAssertEqual(tree.left?.value, 5)
        XCTAssertEqual(tree.right?.right?.value, 15)
        // remove left leaf
        tree = tree.remove(5)
        XCTAssertTrue(tree.isBalanced())
        print(">>> \(tree)")
        XCTAssertEqual(tree.toArray(), [8,10,15])
        // tree is rearranged
        XCTAssertEqual(tree.root, 10)
        XCTAssertEqual(tree.left?.value, 8)
        XCTAssertEqual(tree.right?.value, 15)
        // remove right leaf
        tree = tree.remove(15)
        XCTAssertTrue(tree.isBalanced())
        print(">>> \(tree)")
        XCTAssertEqual(tree.toArray(), [8,10])
        // tree is rearranged
        XCTAssertEqual(tree.root, 8)
        XCTAssertEqual(tree.left?.value, nil)
        XCTAssertEqual(tree.right?.value, 10)
        // remove right leaf
        tree = tree.remove(10)
        XCTAssertTrue(tree.isBalanced())
        print(">>> \(tree)")
        XCTAssertEqual(tree.toArray(), [8])
        // tree is rearranged
        XCTAssertEqual(tree.root, 8)
        XCTAssertNil(tree.left)
        XCTAssertNil(tree.right)
        // remove root
        tree = tree.remove(8)
        XCTAssertTrue(tree.isBalanced())
        print(">>> \(tree)")
        XCTAssertEqual(tree.toArray(), [])
        // tree is rearranged
        XCTAssertNil(tree.root)
        XCTAssertNil(tree.left)
        XCTAssertNil(tree.right)
    }

    func test_remove_child_left() {
        // build and confirm tree
        var tree = ValueBasedBinarySearchTree(from: [8, 5, 10, 4, 9])
        var root = tree.search(value: 8)!
        let node4 = tree.search(value: 4)!
        let node5 = tree.search(value: 5)!
        XCTAssertEqual(root.value, 8)
        XCTAssertEqual(root.left?.value, 5)
        XCTAssertEqual(root.right?.value, 10)
        XCTAssertTrue(node5.left == node4)
        XCTAssertTrue(node5 == tree.parent(of: node4.value!))
        XCTAssertTrue(tree.isBalanced())

        // remove node
        tree = tree.remove(node5)
        XCTAssertTrue(tree.isBalanced())
        root = tree.search(value: 8)!
        XCTAssertEqual(root.left?.value, 4)
        XCTAssertEqual(root.right?.value, 9)
        XCTAssertTrue(tree.left == node4)
        XCTAssertTrue(tree == tree.parent(of: node4.value!))
        XCTAssertNil(node4.left)
        XCTAssertNil(node4.right)
        XCTAssertEqual(tree.count, 4)
        XCTAssertEqual(tree.toArray(), [4, 8, 9, 10])
        // tree was rearranged
        let node9 = tree.search(value: 9)!
        let node10 = tree.search(value: 10)!
        XCTAssertNil(node9.left)
        XCTAssertTrue(node9.right == node10)
        XCTAssertTrue(node9.right == node10)
        XCTAssertTrue(node9 == tree.parent(of: node10.value!))

        tree = tree.remove(node4)
        XCTAssertTrue(tree.isBalanced())
        // tree was rearranged
        root = tree.search(value: 9)!
        XCTAssertEqual(root.left?.value, 8)
        XCTAssertEqual(root.right?.value, 10)
        XCTAssertEqual(tree.count, 3)
        XCTAssertEqual(tree.toArray(), [8, 9, 10])
    }

    func test_remove_child_right() {
        // build and confirm tree
        var tree = ValueBasedBinarySearchTree(from: [8, 5, 10, 6, 11])
        print(">>> \(tree)")
        XCTAssertTrue(tree.isBalanced())
        var node5 = tree.search(value: 5)!
        var node6 = tree.search(value: 6)!
        var node8 = tree.search(value: 8)!
        var node10: ValueBasedBinarySearchTree? = tree.search(value: 10)!
        var node11 = tree.search(value: 11)!
        XCTAssertEqual(tree.count, 5)
        XCTAssertEqual(tree.toArray(), [5, 6, 8, 10, 11])
        // confirm nodes
        XCTAssertTrue(node5.right == node6)
        XCTAssertNil(node5.left)
        XCTAssertTrue(node5 == tree.parent(of: node6.value!))
        XCTAssertTrue(node10?.right == node11)
        XCTAssertNil(node10?.left)
        XCTAssertTrue(node10 == tree.parent(of: node11.value!))
        XCTAssertTrue(node8.value == tree.root)
        XCTAssertTrue(node8.left == node5)
        XCTAssertTrue(node8.right == node10)

        // remove right node - tree is rearranged
        tree = tree.remove(node10!)
        node5 = tree.search(value: 5)!
        node6 = tree.search(value: 6)!
        node8 = tree.search(value: 8)!
        node10 = tree.search(value: 10)
        node11 = tree.search(value: 11)!
        XCTAssertTrue(tree.isBalanced())
        XCTAssertEqual(tree.count, 4)
        XCTAssertEqual(tree.toArray(), [5, 6, 8, 11])
        XCTAssertNil(node10)
        XCTAssertTrue(node6.value == tree.root)
    }

      func test_remove_children() {
        var tree = ValueBasedBinarySearchTree(from: [8, 5, 10, 4, 6, 9, 11])
          print(">>> \(tree)")

          XCTAssertTrue(tree.isBalanced())
          var node4 = tree.search(value: 4)!
          var node5 = tree.search(value: 5)!
          var node6 = tree.search(value: 6)!
          var node8 = tree.search(value: 8)!
          var node9 = tree.search(value: 9)!
          var node10 = tree.search(value: 10)!
          var node11 = tree.search(value: 11)!
          XCTAssertEqual(tree.count, 7)
          XCTAssertEqual(tree.toArray(), [4,5, 6, 8, 9, 10, 11])
          // confirm tree
          XCTAssertTrue(node4.isLeaf)
          XCTAssertTrue(node6.isLeaf)
          XCTAssertTrue(node5.left == node4)
          XCTAssertTrue(node5.right == node6)

          XCTAssertTrue(node9.isLeaf)
          XCTAssertTrue(node11.isLeaf)
          XCTAssertTrue(node10.left == node9)
          XCTAssertTrue(node10.right == node11)

          XCTAssertTrue(tree.isRoot(node8.value!))
          XCTAssertTrue(node8.left == node5)
          XCTAssertTrue(node8.right == node10)

          // remove node
          tree = tree.remove(node5)
          print(">>> \(tree)")
          XCTAssertTrue(tree.isBalanced())
          XCTAssertEqual(tree.count, 6)
          XCTAssertEqual(tree.toArray(), [4, 6, 8, 9, 10, 11])
          node4 = tree.search(value: 4)!
          node5 = tree.search(value: 5) ?? .empty
          node6 = tree.search(value: 6)!
          node8 = tree.search(value: 8)!
          node9 = tree.search(value: 9)!
          node10 = tree.search(value: 10)!
          node11 = tree.search(value: 11)!
          // confirm nodes
          XCTAssertFalse(node4.hasBothChildren)
          XCTAssertFalse(node4.hasLeftChild)
          XCTAssertTrue(node4.isRightChild(node6.value!))

          XCTAssertFalse(node10.hasBothChildren)
          XCTAssertFalse(node10.hasLeftChild)
          XCTAssertTrue(node10.isRightChild(node11.value!))

          XCTAssertFalse(node9.hasBothChildren)
          XCTAssertFalse(node9.hasLeftChild)
          XCTAssertTrue(node9.isRightChild(node10.value!))

          XCTAssertTrue(tree.isRoot(node8.value!))
          XCTAssertTrue(node8.left == node4)
          XCTAssertTrue(node8.right == node9)

          // confirm leafs
          XCTAssertTrue(node6.isLeaf)
          XCTAssertTrue(node4.left == nil)
          XCTAssertTrue(node4.right == node6)
          XCTAssertTrue(node11.isLeaf)
          XCTAssertTrue(node10.left == nil)
          XCTAssertTrue(node10.right == node11)

          // remove node
          tree = tree.remove(node9)
          print(">>> \(tree)")
          XCTAssertTrue(tree.isBalanced())
          XCTAssertEqual(tree.count, 5)
          XCTAssertEqual(tree.toArray(), [4, 6, 8, 10, 11])
          node4 = tree.search(value: 4)!
          node6 = tree.search(value: 6)!
          node8 = tree.search(value: 8)!
          node9 = tree.search(value: 9) ?? .empty
          node10 = tree.search(value: 10)!
          node11 = tree.search(value: 11)!
          // confirm nodes
          XCTAssertFalse(node4.hasBothChildren)
          XCTAssertFalse(node4.hasLeftChild)
          XCTAssertTrue(node4.isRightChild(node6.value!))

          XCTAssertFalse(node10.hasBothChildren)
          XCTAssertFalse(node10.hasLeftChild)
          XCTAssertTrue(node10.isRightChild(node11.value!))

          XCTAssertFalse(node9.hasAnyChild)

          XCTAssertTrue(tree.isRoot(node8.value!))
          XCTAssertTrue(node8.left == node4)
          XCTAssertTrue(node8.right == node10)

          // confirm leafs
          XCTAssertTrue(node6.isLeaf)
          XCTAssertTrue(node4.left == nil)
          XCTAssertTrue(node4.right == node6)
          XCTAssertTrue(node11.isLeaf)
          XCTAssertTrue(node10.left == nil)
          XCTAssertTrue(node10.right == node11)
      }

      func test_remove_child() {
        var tree = ValueBasedBinarySearchTree(from: [8, 5, 10, 4, 9, 20, 11, 15, 13])
          print(">>> \(tree)")
          XCTAssertTrue(tree.isBalanced())
          XCTAssertEqual(tree.toArray(), [4, 5, 8, 9, 10, 11, 13, 15, 20])
          XCTAssertEqual(tree.count, 9)
          XCTAssertEqual(tree.height, 4)

          var node4 = tree.search(value: 4)!
          var node5 = tree.search(value: 5)!
          var node8 = tree.search(value: 8)!
          var node9 = tree.search(value: 9)!
          var node10 = tree.search(value: 10)!
          var node11 = tree.search(value: 11)!
          var node13 = tree.search(value: 13)!
          var node15 = tree.search(value: 15)!
          var node20 = tree.search(value: 20)!

          // confirm nodes
          XCTAssertFalse(node5.hasBothChildren)
          XCTAssertTrue(node5.hasLeftChild)
          XCTAssertTrue(node5.isLeftChild(node4.value!))

          XCTAssertTrue(node8.hasBothChildren)
          XCTAssertTrue(node8.isLeftChild(node5.value!))
          XCTAssertTrue(node8.isRightChild(node9.value!))

          XCTAssertFalse(node20.hasBothChildren)
          XCTAssertFalse(node20.hasRightChild)
          XCTAssertTrue(node20.isLeftChild(node11.value!))

          XCTAssertFalse(node11.hasBothChildren)
          XCTAssertFalse(node11.hasLeftChild)
          XCTAssertTrue(node11.isRightChild(node15.value!))

          XCTAssertFalse(node15.hasBothChildren)
          XCTAssertFalse(node15.hasRightChild)
          XCTAssertTrue(node15.isLeftChild(node13.value!))

          XCTAssertTrue(tree.isRoot(node10.value!))
          XCTAssertTrue(node10.hasBothChildren)
          XCTAssertTrue(node10.left == node8)
          XCTAssertTrue(node10.right == node20)

          // remove root node - tree is rearranged
          tree = tree.remove(node10)
          print(">>> \(tree)")
          XCTAssertTrue(tree.isBalanced())
          XCTAssertEqual(tree.height, 4)
          XCTAssertEqual(tree.toArray(), [4, 5, 8, 9, 11, 13, 15, 20])
          XCTAssertEqual(tree.count, 8)
          node4 = tree.search(value: 4)!
          node5 = tree.search(value: 5)!
          node8 = tree.search(value: 8)!
          node9 = tree.search(value: 9)!
          node10 = tree.search(value: 10) ?? .empty
          node11 = tree.search(value: 11)!
          node13 = tree.search(value: 13)!
          node15 = tree.search(value: 15)!
          node20 = tree.search(value: 20)!

          // confirm new tree
          XCTAssertFalse(node5.hasBothChildren)
          XCTAssertFalse(node5.hasLeftChild)
          XCTAssertTrue(node5.isRightChild(node8.value!))

          XCTAssertFalse(node4.hasBothChildren)
          XCTAssertFalse(node4.hasLeftChild)
          XCTAssertTrue(node4.isRightChild(node5.value!))

          XCTAssertFalse(node15.hasBothChildren)
          XCTAssertFalse(node15.hasLeftChild)
          XCTAssertTrue(node15.isRightChild(node20.value!))

          XCTAssertFalse(node13.hasBothChildren)
          XCTAssertFalse(node13.hasLeftChild)
          XCTAssertTrue(node13.isRightChild(node15.value!))

          XCTAssertFalse(node11.hasBothChildren)
          XCTAssertFalse(node11.hasLeftChild)
          XCTAssertTrue(node11.isRightChild(node13.value!))

          // new root
          XCTAssertTrue(tree.isRoot(node9.value!))
          XCTAssertTrue(node9.hasBothChildren)
          XCTAssertTrue(node9.left == node4)
          XCTAssertTrue(node9.right == node11)
      }

    func test_shake() {
        var tree = ValueBasedBinarySearchTree<Int>()
        tree = tree.insert(8)
        tree = tree.insert(9)
        tree = tree.insert(10)
        tree = tree.insert(11)
        tree = tree.insert(12)
        tree = tree.insert(13)
        print(">>> \(tree)")
        let height0 = tree.height
        XCTAssertEqual(height0, 5)
        XCTAssertFalse(tree.isBalanced(),"tree is unbalanced (linear)")

        var node8 = tree.search(value: 8)!
        var node9 = tree.search(value: 9)!
        var node10 = tree.search(value: 10)!
        var node11 = tree.search(value: 11)!
        var node12 = tree.search(value: 12)!
        var node13 = tree.search(value: 13)!

        // confirm structure
        XCTAssertTrue(tree.isRoot(8))
        XCTAssertTrue(node8.right == node9)
        XCTAssertTrue(node9.right == node10)
        XCTAssertTrue(node10.right == node11)
        XCTAssertTrue(node11.right == node12)
        XCTAssertTrue(node12.right == node13)

        tree = tree.shake()
        print(">>> \(tree)")
        node8 = tree.search(value: 8)!
        node9 = tree.search(value: 9)!
        node10 = tree.search(value: 10)!
        node11 = tree.search(value: 11)!
        node12 = tree.search(value: 12)!
        node13 = tree.search(value: 13)!
        XCTAssertTrue(tree.height < height0)
        XCTAssertTrue(tree.isBalanced())

        // confirm structure
        XCTAssertTrue(tree.isRoot(10))

        XCTAssertTrue(node8.left == nil)
        XCTAssertTrue(node8.right == node9)
        XCTAssertTrue(node9.right == nil)
        XCTAssertTrue(node10.left == node8)
        XCTAssertTrue(node10.right == node11)
        XCTAssertTrue(node11.right == node12)
        XCTAssertTrue(node12.right == node13)
    }

}
