
//
//  BinarySearchTreeTests.swift
//
//
//  Created by Christopher Charles Cavnor on 4/28/22.
//
import XCTest
import TreeProtocol
@testable import BinarySearchTree

import Foundation
import XCTest


// TODO: break into BinarySearchTree versus BinarySearchTreeNode tests
class ReferenceBasedBinarySearchTreeTest: XCTestCase {

    //=======================================
    // BinarySearchTreeNode
    //=======================================

    // test isRoot and isLeaf
    func test_isRoot_isLeaf() {
        let tree = BinarySearchTree(array: [8, 5, 10, 3, 12, 9, 6, 16])
        tree.draw()

        let r = tree.root!
        XCTAssertTrue(r.isRoot) //8
        XCTAssertFalse(r.left!.isRoot) //5
        XCTAssertFalse(r.left!.left!.isRoot) //3
        XCTAssertFalse(r.left!.right!.isRoot) //6
        XCTAssertFalse(r.right!.isRoot) //10
        XCTAssertFalse(r.right!.left!.isRoot) //9
        XCTAssertFalse(r.right!.right!.isRoot) //12
        XCTAssertFalse(r.right!.right!.right!.isRoot) //16

        XCTAssertFalse(r.isLeaf) //8
        XCTAssertFalse(r.left!.isLeaf) //5
        XCTAssertTrue(r.left!.left!.isLeaf) //3
        XCTAssertTrue(r.left!.right!.isLeaf) //6
        XCTAssertFalse(r.right!.isLeaf) //10
        XCTAssertTrue(r.right!.left!.isLeaf) //9
        XCTAssertFalse(r.right!.right!.isLeaf) //12
        XCTAssertTrue(r.right!.right!.right!.isLeaf) //16
    }

    // test isLeftChild and isRightChild
    func test_isLeftChild_isRightChild() {
        let tree = BinarySearchTree(array: [8, 5, 10, 3, 12, 9, 6, 16])
        tree.draw()

        let r = tree.root!
        XCTAssertFalse(r.isLeftChild) //8
        XCTAssertTrue(r.left!.isLeftChild) //5
        XCTAssertTrue(r.left!.left!.isLeftChild) //3
        XCTAssertFalse(r.left!.right!.isLeftChild) //6
        XCTAssertFalse(r.right!.isLeftChild) //10
        XCTAssertTrue(r.right!.left!.isLeftChild) //9
        XCTAssertFalse(r.right!.right!.isLeftChild) //12
        XCTAssertFalse(r.right!.right!.right!.isLeftChild) //16

        XCTAssertFalse(r.isRightChild) //8
        XCTAssertFalse(r.left!.isRightChild) //5
        XCTAssertFalse(r.left!.left!.isRightChild) //3
        XCTAssertTrue(r.left!.right!.isRightChild) //6
        XCTAssertTrue(r.right!.isRightChild) //10
        XCTAssertFalse(r.right!.left!.isRightChild) //9
        XCTAssertTrue(r.right!.right!.isRightChild) //12
        XCTAssertTrue(r.right!.right!.right!.isRightChild) //16
    }

    // test hasLeftChild and hasRightChild
    func test_hasLeftChild_hasRightChild() {
        let tree = BinarySearchTree(array: [8, 5, 10, 3, 12, 9, 6, 16])
        tree.draw()

        let r = tree.root!
        XCTAssertTrue(r.hasLeftChild) //8
        XCTAssertTrue(r.left!.hasLeftChild) //5
        XCTAssertFalse(r.left!.left!.hasLeftChild) //3
        XCTAssertFalse(r.left!.right!.hasLeftChild) //6
        XCTAssertTrue(r.right!.hasLeftChild) //10
        XCTAssertFalse(r.right!.left!.hasLeftChild) //9
        XCTAssertFalse(r.right!.right!.hasLeftChild) //12
        XCTAssertFalse(r.right!.right!.right!.hasLeftChild) //16

        XCTAssertTrue(r.hasRightChild) //8
        XCTAssertTrue(r.left!.hasRightChild) //5
        XCTAssertFalse(r.left!.left!.hasRightChild) //3
        XCTAssertFalse(r.left!.right!.hasRightChild) //6
        XCTAssertTrue(r.right!.hasRightChild) //10
        XCTAssertFalse(r.right!.left!.hasRightChild) //9
        XCTAssertTrue(r.right!.right!.hasRightChild) //12
        XCTAssertFalse(r.right!.right!.right!.hasRightChild) //16
    }


    // test hasAnyChild and hasBothChildren
    func test_hasAnyChild_hasBothChildren() {
        let tree = BinarySearchTree(array: [8, 5, 10, 3, 12, 9, 6, 16])
        tree.draw()

        let r = tree.root!
        XCTAssertTrue(r.hasAnyChild) //8
        XCTAssertTrue(r.left!.hasAnyChild) //5
        XCTAssertFalse(r.left!.left!.hasAnyChild) //3
        XCTAssertFalse(r.left!.right!.hasAnyChild) //6
        XCTAssertTrue(r.right!.hasAnyChild) //10
        XCTAssertFalse(r.right!.left!.hasAnyChild) //9
        XCTAssertTrue(r.right!.right!.hasAnyChild) //12
        XCTAssertFalse(r.right!.right!.right!.hasAnyChild) //16

        XCTAssertTrue(r.hasBothChildren) //8
        XCTAssertTrue(r.left!.hasBothChildren) //5
        XCTAssertFalse(r.left!.left!.hasBothChildren) //3
        XCTAssertFalse(r.left!.right!.hasBothChildren) //6
        XCTAssertTrue(r.right!.hasBothChildren) //10
        XCTAssertFalse(r.right!.left!.hasBothChildren) //9
        XCTAssertFalse(r.right!.right!.hasBothChildren) //12
        XCTAssertFalse(r.right!.right!.right!.hasBothChildren) //16
    }

    // test ==
    func test_equality() {
        let tree = BinarySearchTree(array: [8, 5, 10, 3, 12, 9, 6, 16])
        tree.draw()

        let n0 = BinarySearchTreeNode(value: 8)
        let n1 = BinarySearchTreeNode(value: 5)
        let n2 = BinarySearchTreeNode(value: 16)

        let r = tree.root!
        XCTAssertTrue(r == n0)
        XCTAssertFalse(r == n1)
        XCTAssertFalse(r == n2)
    }

    // test <, >, <=, >=
    func test_inequalities() {
        let tree = BinarySearchTree(array: [8, 5, 10, 3, 12, 9, 6, 16])
        tree.draw()

        let n0 = BinarySearchTreeNode(value: 8)
        let n1 = BinarySearchTreeNode(value: 5)
        let n2 = BinarySearchTreeNode(value: 16)

        let r = tree.root!
        XCTAssertFalse(r < n0)
        XCTAssertFalse(r < n1)
        XCTAssertTrue(r < n2)

        XCTAssertFalse(r > n0)
        XCTAssertTrue(r > n1)
        XCTAssertFalse(r > n2)

        XCTAssertTrue(r >= n0)
        XCTAssertTrue(r >= n1)
        XCTAssertFalse(r >= n2)

        XCTAssertTrue(r <= n0)
        XCTAssertFalse(r <= n1)
        XCTAssertTrue(r <= n2)
    }

    //=======================================
    // BinarySearchTree
    //=======================================
    func testInsert() {
        let tree = BinarySearchTree(value: 8)
        try! tree.insert(node: BinarySearchTreeNode(value: 3))
        try! tree.insert(node: BinarySearchTreeNode(value: 9))
        try! tree.insert(node: BinarySearchTreeNode(value: 10))
        try! tree.insert(node: BinarySearchTreeNode(value: 10)) // duplicate value should be ignored
        try! tree.insert(node: BinarySearchTreeNode(value:1))
        try! tree.insert(node: BinarySearchTreeNode(value: 2))
        tree.draw()

        XCTAssertEqual(tree.size, 6)
        XCTAssertEqual(tree.height(), 4) // left is heavier than right

        // root
        let root = tree.root!
        XCTAssertEqual(root.value, 8)

        // left subtree
        let node3 = root.left
        XCTAssertEqual(node3?.value, 3)
        XCTAssertEqual(node3?.left?.value, 1)
        XCTAssertNil(node3?.right?.value)
        XCTAssertTrue(node3?.parent === root)

        let node1 = root.left!.left
        XCTAssertEqual(node1?.value, 1)
        XCTAssertNil(node1?.left?.value)
        XCTAssertEqual(node1?.right?.value, 2)
        XCTAssertTrue(node1?.parent === node3)

        let node2 = root.left!.left!.right
        XCTAssertEqual(node2?.value, 2)
        XCTAssertNil(node2?.left)
        XCTAssertNil(node2?.right)
        XCTAssertTrue(node2?.parent === node1)

        // right subtree
        let node9 = root.right!
        XCTAssertEqual(node9.value, 9)
        XCTAssertNil(node9.left?.value)
        XCTAssertEqual(node9.right?.value, 10)
        XCTAssertTrue(node9.parent === root)

        let node10 = root.right!.right!
        XCTAssertEqual(node10.value, 10)
        XCTAssertNil(node10.left)
        XCTAssertNil(node10.right)
        XCTAssertTrue(node10.parent === node9)
    }

    func testCreateFromArray() {
        let tree = BinarySearchTree(array: [8, 5, 10, 3, 12, 9, 6, 16])
        tree.draw()
        XCTAssertEqual(tree.size, 8)
        XCTAssertEqual(tree.height(), 4)
        XCTAssertEqual(tree.toArray(), [3, 5, 6, 8, 9, 10, 12, 16])

        let n8 = tree.search(value: 8)!
        let n5 = tree.search(value: 5)!
        let n10 = tree.search(value: 10)!
        let n3 = tree.search(value: 3)!
        let n12 = tree.search(value: 12)!
        let n9 = tree.search(value: 9)!
        let n6 = tree.search(value: 6)!
        let n16 = tree.search(value: 16)!

        // min and max
        XCTAssertEqual(tree.minimum()?.value, 3)
        XCTAssertEqual(tree.maximum()?.value, 16)
        // test node positions
        XCTAssertTrue(n8.isRoot)
        // left subtree
        XCTAssertTrue(n8.left === n5)
        XCTAssertTrue(n5.left === n3)
        XCTAssertTrue(n5.right === n6)
        XCTAssertTrue(n3.isLeaf)
        XCTAssertTrue(n6.isLeaf)
        // right subtree
        XCTAssertTrue(n8.right === n10)
        XCTAssertTrue(n10.left === n9)
        XCTAssertTrue(n10.right === n12)
        XCTAssertTrue(n10.right?.right === n16) // or 12 right
        XCTAssertTrue(n9.isLeaf)
        XCTAssertTrue(n16.isLeaf)
    }

    // test the height and size functions for whole tree
    func testTreeHeightCount() {
        // test tree of zero and one node
        let root = BinarySearchTree(value: 8)
        XCTAssertEqual(root.size, 1)
        XCTAssertEqual(root.height(), 1)
        root.remove(value: 8)
        XCTAssertEqual(root.size, 0)
        XCTAssertEqual(root.height(), 0)

        // test full tree ( 3 <- 5 -> 6 <- 8 -> 9 -> 10 -> 12 -> 16 )
        // where final left height is 3 and final right height is 5
        let tree = BinarySearchTree(value: 8)
        XCTAssertEqual(tree.size, 1)
        XCTAssertEqual(tree.height(), 1)

        //try! tree.insert(value: 5)
        try! tree.insert(node: BinarySearchTreeNode(value: 5))
        tree.draw()
        XCTAssertEqual(tree.size, 2)
        XCTAssertEqual(tree.height(), 2)

        //try! tree.insert(value: 3)
        try! tree.insert(node: BinarySearchTreeNode(value: 3))
        tree.draw()
        XCTAssertEqual(tree.size, 3)
        XCTAssertEqual(tree.height(), 3)

        //try! tree.insert(value: 6)
        try! tree.insert(node: BinarySearchTreeNode(value: 6))
        tree.draw()
        XCTAssertEqual(tree.size, 4)
        XCTAssertEqual(tree.height(), 3)

        //try! tree.insert(value: 9)
        try! tree.insert(node: BinarySearchTreeNode(value: 9))
        tree.draw()
        XCTAssertEqual(tree.size, 5)
        XCTAssertEqual(tree.height(), 3)

        //try! tree.insert(value: 10)
        try! tree.insert(node: BinarySearchTreeNode(value: 10))
        tree.draw()
        XCTAssertEqual(tree.size, 6)
        XCTAssertEqual(tree.height(), 3)

        //try! tree.insert(value: 12)
        try! tree.insert(node: BinarySearchTreeNode(value: 12))
        tree.draw()
        XCTAssertEqual(tree.size, 7)
        XCTAssertEqual(tree.height(), 4)

        //try! tree.insert(value: 16)
        try! tree.insert(node: BinarySearchTreeNode(value: 16))
        tree.draw()
        XCTAssertEqual(tree.size, 8)
        XCTAssertEqual(tree.height(), 5)
    }

    // test the height and size functions for node
    func testNodeHeightCount() {
        // test tree of zero and one node
        let rootTree = BinarySearchTree(value: 8)
        XCTAssertEqual(rootTree.size, 1)
        XCTAssertEqual(rootTree.height(node: rootTree.root), 1)
        rootTree.remove(value: 8)
        XCTAssertEqual(rootTree.size, 0)
        XCTAssertEqual(rootTree.height(node: rootTree.root), 0)

        // test full tree ( 3 <- 5 -> 6 <- 8 -> 9 -> 10 -> 12 -> 16 )
        // where final left height is 3 and final right height is 5
        let tree = BinarySearchTree(value: 8)
        let node = tree.search(value: 8)
        XCTAssertEqual(tree.size, 1)
        XCTAssertEqual(tree.height(node: node), 1)

        //try! tree.insert(value: 5)
        try! tree.insert(node: BinarySearchTreeNode(value: 5))
        tree.draw()
        XCTAssertEqual(tree.size, 2)
        XCTAssertEqual(tree.height(), 2)

        //try! tree.insert(value: 3)
        try! tree.insert(node: BinarySearchTreeNode(value: 3))
        tree.draw()
        XCTAssertEqual(tree.size, 3)
        XCTAssertEqual(tree.height(), 3)

        //try! tree.insert(value: 6)
        try! tree.insert(node: BinarySearchTreeNode(value: 6))
        tree.draw()
        XCTAssertEqual(tree.size, 4)
        XCTAssertEqual(tree.height(), 3)

        //try! tree.insert(value: 9)
        try! tree.insert(node: BinarySearchTreeNode(value: 9))
        tree.draw()
        XCTAssertEqual(tree.size, 5)
        XCTAssertEqual(tree.height(), 3)

        //try! tree.insert(value: 10)
        try! tree.insert(node: BinarySearchTreeNode(value: 10))
        tree.draw()
        XCTAssertEqual(tree.size, 6)
        XCTAssertEqual(tree.height(), 3)

        //try! tree.insert(value: 12)
        try! tree.insert(node: BinarySearchTreeNode(value: 12))
        tree.draw()
        XCTAssertEqual(tree.size, 7)
        XCTAssertEqual(tree.height(), 4)

        //try! tree.insert(value: 16)
        try! tree.insert(node: BinarySearchTreeNode(value: 16))
        tree.draw()
        XCTAssertEqual(tree.size, 8)
        XCTAssertEqual(tree.height(), 5)
    }

    // test if value is in left or right subtree of root
    func testTreeLeftRightChild() {
        // nodes 3,5,6 are left of root
        // nodes 9,10,12,16 are right of root
        let tree = BinarySearchTree(array: [8, 5, 10, 3, 12, 9, 6, 16])
        tree.draw()
        // root node
        XCTAssertFalse(tree.inLeftTree(value: 8))
        XCTAssertFalse(tree.inRightTree(value: 8))

        // left subtree
        XCTAssertTrue(tree.inLeftTree(value: 3))
        XCTAssertFalse(tree.inRightTree(value: 3))
        XCTAssertTrue(tree.inLeftTree(value: 5))
        XCTAssertFalse(tree.inRightTree(value: 5))
        XCTAssertTrue(tree.inLeftTree(value: 6))
        XCTAssertFalse(tree.inRightTree(value: 6))
        // right subtree
        XCTAssertFalse(tree.inLeftTree(value: 9))
        XCTAssertTrue(tree.inRightTree(value: 9))
        XCTAssertFalse(tree.inLeftTree(value: 10))
        XCTAssertTrue(tree.inRightTree(value: 10))
        XCTAssertFalse(tree.inLeftTree(value: 12))
        XCTAssertTrue(tree.inRightTree(value: 12))
        XCTAssertFalse(tree.inLeftTree(value: 16))
        XCTAssertTrue(tree.inRightTree(value: 16))
    }

    // test isRoot, isLeftChild, isRightChild
    func testNodeLeftRightChild() {
        // node 8 (root) has no parent so is always false
        // nodes 3,5,9 are left of their respective parent node
        // nodes 6,10,12,16 are right of their respective parent node
        let tree = BinarySearchTree(array: [8, 5, 10, 3, 12, 9, 6, 16])
        tree.draw()
        let n8 = tree.search(value: 8)
        let n5 = tree.search(value: 5)
        let n10 = tree.search(value: 10)
        let n3 = tree.search(value: 3)
        let n12 = tree.search(value: 12)
        let n9 = tree.search(value: 9)
        let n6 = tree.search(value: 6)
        let n16 = tree.search(value: 16)
        XCTAssertTrue(n8!.isRoot)
        XCTAssertFalse(n8!.isLeftChild)
        XCTAssertFalse(n8!.isRightChild)

        // left nodes
        XCTAssertTrue(n3!.isLeftChild)
        XCTAssertFalse(n3!.isRightChild)
        XCTAssertTrue(n5!.isLeftChild)
        XCTAssertFalse(n5!.isRightChild)
        XCTAssertTrue(n9!.isLeftChild)
        XCTAssertFalse(n9!.isRightChild)
        // right nodes
        XCTAssertTrue(n6!.isRightChild)
        XCTAssertFalse(n6!.isLeftChild)
        XCTAssertTrue(n10!.isRightChild)
        XCTAssertFalse(n10!.isLeftChild)
        XCTAssertTrue(n12!.isRightChild)
        XCTAssertFalse(n12!.isLeftChild)
        XCTAssertTrue(n16!.isRightChild)
        XCTAssertFalse(n16!.isLeftChild)
    }

    func testSearch() {
        let tree = BinarySearchTree(array: [3, 1, 2, 5, 4])
        tree.draw()

        // test value not found
        let empty = tree.search(value: 9)
        XCTAssertEqual(empty?.value, nil)

        // test root as target
        XCTAssertTrue(tree.root?.value == 3)
        let n0 = tree.search(value: 3)
        XCTAssertEqual(n0?.value, 3)

        // left
        let n1 = tree.search(value: 1)
        XCTAssertEqual(n1?.value, 1)

        // left leaf
        let n2 = tree.search(value: 2)
        XCTAssertEqual(n2?.value, 2)

        // right
        let n3 = tree.search(value: 5)
        XCTAssertEqual(n3?.value, 5)

        // right leaf
        let n4 = tree.search(value: 4)
        XCTAssertEqual(n4?.value, 4)
    }

    // The min and max for the entire tree
    func testTreeMinMax() {
        let tree = BinarySearchTree(array: [8, 5, 10, 3, 12, 9, 6, 16])
        tree.draw()
        // tree min and max
        let tree_min = tree.minimum()!
        XCTAssertEqual(tree_min.value, 3)
        XCTAssertTrue(tree_min.isLeaf)

        let tree_max = tree.maximum()!
        XCTAssertEqual(tree_max.value, 16)
        XCTAssertTrue(tree_max.isLeaf)

        // node-based min and max
        let node5 = tree.search(value: 5)!
        XCTAssertEqual(tree.minimum(node: node5)?.value, 3)
        XCTAssertEqual(tree.maximum(node: node5)?.value, 6)

        let node10 = tree.search(value: 10)!
        XCTAssertEqual(tree.minimum(node: node10)?.value, 9)
        XCTAssertEqual(tree.maximum(node: node10)?.value, 16)

        // make sure that leaf nodes return themselves
        let leaf3 = tree.search(value: 3)! // left node
        XCTAssertEqual(tree.minimum(node: leaf3)?.value, 3)
        XCTAssertEqual(tree.maximum(node: leaf3)?.value, 3)

        let leaf16 = tree.search(value: 16)! // left node
        XCTAssertEqual(tree.minimum(node: leaf16)?.value, 16)
        XCTAssertEqual(tree.maximum(node: leaf16)?.value, 16)
    }


    // test the min and max for the given node
    func testMinMaxNode() {
        let root_tree = BinarySearchTree(array: [10])
        XCTAssertEqual(root_tree.minimum(node: root_tree.root!)?.value, 10, "min value for tree is root itself")
        XCTAssertEqual(root_tree.maximum(node: root_tree.root!)?.value, 10, "max value for node is root itself")

        let tiny_tree = BinarySearchTree(array: [10,2,12])
        tiny_tree.draw()
        XCTAssertEqual(tiny_tree.minimum(node: tiny_tree.root!)?.value, 2)
        XCTAssertEqual(tiny_tree.maximum(node: tiny_tree.root!)?.value, 12)

        let left_leaf = tiny_tree.root!.left!
        XCTAssertEqual(tiny_tree.minimum(node: left_leaf)!.value, 2, "min value of leaf is leaf")
        XCTAssertEqual(tiny_tree.maximum(node: left_leaf)!.value, 2, "max value of leaf is leaf")

        let right_leaf = tiny_tree.root!.right!
        XCTAssertEqual(tiny_tree.minimum(node: right_leaf)!.value, 12, "min value of leaf is leaf")
        XCTAssertEqual(tiny_tree.maximum(node: right_leaf)!.value, 12, "max value of leaf is leaf")

        let tree = BinarySearchTree(array: [10,5,20,3,8,14,25,1,4,6,9,12,15,23,26])
        tree.draw()

        // assert structure
        let root = tree.root!
        let rl = root.left! // 5
        let rr = root.right! // 20
        let rll = rl.left! // 3
        let rlr = rl.right! // 8
        let rrl = rr.left! // 14
        let rrr = rr.right! // 25
        let rlll = rll.left! // 1
        let rllr = rll.right! // 4
        let rlrl = rlr.left! // 6
        let rlrr = rlr.right! // 9
        let rrll = rrl.left! // 12
        let rrlr = rrl.right! // 15
        let rrrl = rrr.left! // 23
        let rrrr = rrr.right! // 26

        XCTAssertEqual(root.value, 10)
        XCTAssertEqual(rl.value, 5)
        XCTAssertEqual(rr.value, 20)
        XCTAssertEqual(rll.value, 3)
        XCTAssertEqual(rlr.value, 8)
        XCTAssertEqual(rrr.value, 25)
        XCTAssertEqual(rlll.value, 1)
        XCTAssertEqual(rllr.value, 4)
        XCTAssertEqual(rlrl.value, 6)
        XCTAssertEqual(rlrr.value, 9)
        XCTAssertEqual(rrll.value, 12)
        XCTAssertEqual(rrlr.value, 15)
        XCTAssertEqual(rrrl.value, 23)
        XCTAssertEqual(rrrr.value, 26)

        // mins
        XCTAssertEqual(tree.minimum(node: root)?.value, 1, "min value for tree")
        // left subtree of root
        XCTAssertEqual(tree.minimum(node: rl)?.value, 1, "min value for node 5")
        XCTAssertEqual(tree.minimum(node: rll)?.value, 1, "min value for node 3")
        XCTAssertEqual(tree.minimum(node: rlr)?.value, 6, "min value for node 8")
        XCTAssertEqual(tree.minimum(node: rlll)?.value, 1, "min value of leaf is leaf value")
        XCTAssertEqual(tree.minimum(node: rllr)?.value, 4, "min value of leaf is leaf value")
        XCTAssertEqual(tree.minimum(node: rlrl)?.value, 6, "min value of leaf is leaf value")
        XCTAssertEqual(tree.minimum(node: rlrr)?.value, 9, "min value of leaf is leaf value")
        // right subtree of root
        XCTAssertEqual(tree.minimum(node: rr)?.value, 12, "min value for node 20")
        XCTAssertEqual(tree.minimum(node: rrl)?.value, 12, "min value for node 14")
        XCTAssertEqual(tree.minimum(node: rrr)?.value, 23, "min value for node 25")
        XCTAssertEqual(tree.minimum(node: rrll)?.value, 12, "min value of leaf is leaf value")
        XCTAssertEqual(tree.minimum(node: rrlr)?.value, 15, "min value of leaf is leaf value")
        XCTAssertEqual(tree.minimum(node: rrrl)?.value, 23, "min value of leaf is leaf value")
        XCTAssertEqual(tree.minimum(node: rrrr)?.value, 26, "min value of leaf is leaf value")

        // max
        XCTAssertEqual(tree.maximum(node: root)?.value, 26, "max value for tree")
        // left subtree of root
        XCTAssertEqual(tree.maximum(node: rl)?.value, 9, "max value for node 5")
        XCTAssertEqual(tree.maximum(node: rll)?.value, 4, "max value for node 3")
        XCTAssertEqual(tree.maximum(node: rlr)?.value, 9, "max value for node 8")
        XCTAssertEqual(tree.maximum(node: rlll)?.value, 1, "max value of leaf is leaf value")
        XCTAssertEqual(tree.maximum(node: rllr)?.value, 4, "max value of leaf is leaf value")
        XCTAssertEqual(tree.maximum(node: rlrl)?.value, 6, "max value of leaf is leaf value")
        XCTAssertEqual(tree.maximum(node: rlrr)?.value, 9, "max value of leaf is leaf value")
        // right subtree of root
        XCTAssertEqual(tree.maximum(node: rr)?.value, 26, "max value for node 20")
        XCTAssertEqual(tree.maximum(node: rrl)?.value, 15, "max value for node 14")
        XCTAssertEqual(tree.maximum(node: rrr)?.value, 26, "max value for node 25")
        XCTAssertEqual(tree.maximum(node: rrll)?.value, 12, "max value of leaf is leaf value")
        XCTAssertEqual(tree.maximum(node: rrlr)?.value, 15, "max value of leaf is leaf value")
        XCTAssertEqual(tree.maximum(node: rrrl)?.value, 23, "max value of leaf is leaf value")
        XCTAssertEqual(tree.maximum(node: rrrr)?.value, 26, "max value of leaf is leaf value")
    }


    // map takes function: (BinarySearchTree) -> BinarySearchTree) and returns [BinarySearchTreeNode<T>]
    func testMap() {
        let tree = BinarySearchTree(array: [3, 1, 2, 5, 4])
        tree.draw()
        // first, lets just pass through the node values
        let r0 = tree.map( { $0 } )
        XCTAssertEqual(r0, [1,2,3,4,5])
        // now let's apply a mutation function
        let r1 = tree.map( { $0 * 2} )
        XCTAssertEqual(r1, [2,4,6,8,10])
        // make sure that tree was changed too
        XCTAssertEqual(6, tree.root?.value)
        XCTAssertEqual(2, tree.root?.left?.value)
        XCTAssertEqual(4, tree.root?.left?.right?.value)
        XCTAssertEqual(10, tree.root?.right?.value)
        XCTAssertEqual(8, tree.root?.right?.left?.value)
    }

    // flatMap takes function: (BinarySearchTree) -> BinarySearchTree) and returns [BinarySearchTreeNode<T>]
    func testFlatMap() {
        let tree = BinarySearchTree(array: [3, 1, 2, 5, 4])
        tree.draw()
        // first, lets just pass through the node values
        let r0 = tree.map( { $0 } )
        XCTAssertEqual(r0, [1,2,3,4,5])
        // now let's apply a mutation function
        let r1 = tree.map( { $0 * 2} )
        XCTAssertEqual(r1, [2,4,6,8,10])
        // make sure that tree was changed too
        XCTAssertEqual(6, tree.root?.value)
        XCTAssertEqual(2, tree.root?.left?.value)
        XCTAssertEqual(4, tree.root?.left?.right?.value)
        XCTAssertEqual(10, tree.root?.right?.value)
        XCTAssertEqual(8, tree.root?.right?.left?.value)
    }

    func testTraversing() {
        let tree = BinarySearchTree(array: [8,5,4,6,12,10,13])
        tree.draw()

        // in-order traversal
        var inOrder = [Int]()
        tree.traverseInOrder { inOrder.append($0) }
        XCTAssertEqual(inOrder, [4, 5, 6, 8, 10, 12, 13])

        // pre-order traversal
        var preOrder = [Int]()
        tree.traversePreOrder { preOrder.append($0) }
        XCTAssertEqual(preOrder, [8,5,4,6,12,10,13])

        // post-order traversal
        var postOrder = [Int]()
        tree.traversePostOrder { postOrder.append($0) }
        XCTAssertEqual(postOrder, [4,6,5,10,13,12,8])
    }

    func testRemoveLeaf() {
        let tree = BinarySearchTree(array: [8, 5, 10, 4])
        tree.draw()

        let node10 = tree.search(value: 10)!
        XCTAssertNil(node10.left)
        XCTAssertNil(node10.right)
        XCTAssertTrue(node10.parent === tree.root)

        let node5 = tree.search(value: 5)!
        XCTAssertTrue(node5.parent?.value == 8)
        XCTAssertTrue(node5.left?.value == 4)
        XCTAssertNil(node5.right)

        let node4 = tree.search(value: 4)!
        XCTAssertTrue(node4.parent?.value == 5)
        XCTAssertNil(node4.left)
        XCTAssertNil(node4.right)

        // remove node 4
        tree.remove(value: 4)
        tree.draw()
        XCTAssertTrue(tree.size == 3)
        XCTAssertEqual(tree.root?.value, 8)
        XCTAssertEqual(tree.root?.left?.value, 5)
        XCTAssertEqual(tree.root?.right?.value, 10)

        // remove node 5
        tree.remove(value: 5)
        tree.draw()
        XCTAssertTrue(tree.size == 2)
        XCTAssertEqual(tree.root?.value, 8)
        XCTAssertNil(tree.root?.left)
        XCTAssertEqual(tree.root?.right?.value, 10)

        // remove node 10
        tree.remove(value: 10)
        tree.draw()
        XCTAssertTrue(tree.size == 1)
        XCTAssertEqual(tree.root?.value, 8)
        XCTAssertNil(tree.root?.left)
        XCTAssertNil(tree.root?.right)

        // tree has only root node now
        tree.remove(value: 8)
        tree.draw()
        XCTAssertTrue(tree.size == 0)
        XCTAssertNil(tree.root)
    }

    // remove an internal node (one with children) from left subtree
    func testRemoveInnerNode() {
        let tree = BinarySearchTree(array: [8, 4, 2, 5, 10, 9, 12])
        tree.draw()
        XCTAssertTrue(tree.size == 7)

        // root of tree
        let root = tree.root!
        XCTAssertTrue(root.value == 8)

        // left subtree
        var node4 = tree.search(value: 4)!
        var node2 = tree.search(value: 2)!
        var node5 = tree.search(value: 5)!

        // right subtree
        var node10 = tree.search(value: 10)!
        var node9 = tree.search(value: 9)!
        var node12 = tree.search(value: 12)!

        //---- validate structure
        XCTAssertTrue(tree.size == 7)
        XCTAssertTrue(tree.root === root)
        // left
        XCTAssertTrue(root.left === node4)
        XCTAssertTrue(node4.left === node2)
        XCTAssertTrue(node4.right === node5)
        XCTAssertFalse(node2.hasAnyChild)
        XCTAssertFalse(node5.hasAnyChild)
        // right
        XCTAssertTrue(root.right === node10)
        XCTAssertTrue(node10.left === node9)
        XCTAssertTrue(node10.right === node12)
        XCTAssertFalse(node9.hasAnyChild)
        XCTAssertFalse(node12.hasAnyChild)

        // remove inner node from left subtree
        tree.remove(value: 4)
        tree.draw()
        XCTAssertTrue(tree.size == 6)
        // references to nodes has changed
        XCTAssertFalse(root.left === node5)
        XCTAssertFalse(node5.left === node2)
        // but their values are as expected
        XCTAssertEqual(2, root.left?.value)
        XCTAssertEqual(5, root.left?.right?.value)
        // we can re-search the nodes to get the expected references
        node2 = tree.search(value: 2)!
        node5 = tree.search(value: 5)!
        XCTAssertTrue(root.left === node2)
        XCTAssertTrue(node2.right === node5)
        XCTAssertTrue(node5.isLeaf)

        // remove inner node from right subtree
        tree.remove(value: 10)
        tree.draw()
        XCTAssertTrue(tree.size == 5)
        XCTAssertTrue(root.left === node2)
        XCTAssertTrue(node2.right === node5)
        XCTAssertTrue(node5.isLeaf)
        XCTAssertNil(node5.right)
        node12 = tree.search(value: 12)!
        node9 = tree.search(value: 9)!
        XCTAssertTrue(root.right === node9)
        XCTAssertTrue(node9.right === node12)
        XCTAssertTrue(node12.isLeaf)

        // remove root of tree
        tree.remove(value: 8)
        XCTAssertTrue(tree.size == 4)
        tree.draw()
        XCTAssertTrue(tree.size == 4)
        node9 = tree.search(value: 9)!
        XCTAssertTrue(tree.root?.value == 5)
        XCTAssertTrue(tree.root?.left === node2)
        XCTAssertTrue(tree.root?.right === node9)

        // remove inner node from left subtree
        tree.remove(value: 5)
        XCTAssertTrue(tree.size == 3)
        node2 = tree.search(value: 2)!
        tree.draw()
        XCTAssertTrue(node2.isRoot)
        XCTAssertTrue(node2.right === node9)
        XCTAssertTrue(node9.right === node12)
        XCTAssertTrue(node12.isLeaf)

        // remove new root
        tree.remove(value: 2)
        XCTAssertTrue(tree.size == 2)
        tree.draw()
        node9 = tree.search(value: 9)!
        XCTAssertTrue(node9.isRoot)
        XCTAssertFalse(node9.hasLeftChild)
        XCTAssertTrue(node9.hasRightChild)
        XCTAssertTrue(node12.isLeaf)

        // remove remaining child
        tree.remove(value: 12)
        XCTAssertTrue(tree.size == 1)
        tree.draw()
        XCTAssertTrue(node9.isRoot)
        XCTAssertFalse(node9.hasAnyChild)

        // remove only remaining node
        tree.remove(value: 9)
        XCTAssertTrue(tree.size == 0)
        XCTAssertTrue(tree.height() == 0)
        tree.draw()
        XCTAssertNil(tree.root)
    }

    func testPredecessor() {
        let tree = BinarySearchTree(array: [10,5,20,3,8,14,25,1,4,6,9,12,15,23,26])
        tree.draw()
        // predecessor of root
        XCTAssertEqual(tree.predecessor(value: 10),9)
        // left subtree
        XCTAssertEqual(tree.predecessor(value: 1),nil)
        XCTAssertEqual(tree.predecessor(value: 3),1)
        XCTAssertEqual(tree.predecessor(value: 4),3)
        XCTAssertEqual(tree.predecessor(value: 5),4)
        XCTAssertEqual(tree.predecessor(value: 6),5)
        XCTAssertEqual(tree.predecessor(value: 8),6)
        XCTAssertEqual(tree.predecessor(value: 9),8)
        // right subtree
        XCTAssertEqual(tree.predecessor(value: 12),10)
        XCTAssertEqual(tree.predecessor(value: 14),12)
        XCTAssertEqual(tree.predecessor(value: 15),14)
        XCTAssertEqual(tree.predecessor(value: 20),15)
        XCTAssertEqual(tree.predecessor(value: 23),20)
        XCTAssertEqual(tree.predecessor(value: 25),23)
        XCTAssertEqual(tree.predecessor(value: 26),25)
        // values not in tree
        XCTAssertNil(tree.predecessor(value: 0), "preceedes tree values")
        XCTAssertNil(tree.predecessor(value: 27), "beyond tree values")
        XCTAssertNil(tree.predecessor(value: 11), "within tree values")
    }

    func testSuccessor() {
        let tree = BinarySearchTree(array: [10,5,20,3,8,14,25,1,4,6,9,12,15,23,26])
        tree.draw()
        // successor of root
        XCTAssertEqual(tree.successor(value: 10),12)
        // left subtree
        XCTAssertEqual(tree.successor(value: 1),3)
        XCTAssertEqual(tree.successor(value: 3),4)
        XCTAssertEqual(tree.successor(value: 4),5)
        XCTAssertEqual(tree.successor(value: 5),6)
        XCTAssertEqual(tree.successor(value: 6),8)
        XCTAssertEqual(tree.successor(value: 8),9)
        XCTAssertEqual(tree.successor(value: 9),10)
        // right subtree
        XCTAssertEqual(tree.successor(value: 12),14)
        XCTAssertEqual(tree.successor(value: 14),15)
        XCTAssertEqual(tree.successor(value: 15),20)
        XCTAssertEqual(tree.successor(value: 20),23)
        XCTAssertEqual(tree.successor(value: 23),25)
        XCTAssertEqual(tree.successor(value: 25),26)
        XCTAssertEqual(tree.successor(value: 26),nil)
        // values not in tree
        XCTAssertNil(tree.successor(value: 0), "preceedes tree values")
        XCTAssertNil(tree.successor(value: 27), "beyond tree values")
        XCTAssertNil(tree.successor(value: 11), "within tree values")
    }

    //-------------------------------------
    // Subscript access
    //-------------------------------------
    func testSubscripting() {
        let tree = BinarySearchTree(array: [10,5,20,3,8,14,25])
        tree.draw()

        // get values
        XCTAssertEqual(tree[10], 10)
        XCTAssertEqual(tree[14], 14)
        XCTAssertEqual(tree[10], 10)
        XCTAssertEqual(tree[55], nil, "value not in tree")

        // change values: tree structure will changes unless we are editing a leaf node,
        // the BST is valid but BST does not auto-balance
        XCTAssertEqual(tree.root?.value, 10)
        XCTAssertTrue(tree.size == 7)
        XCTAssertTrue(tree.height() == 3)
        tree[3] = 4 // edit tree root
        XCTAssertNil(tree.search(value: 3))
        XCTAssertNotNil(tree.search(value: 4))
        XCTAssertEqual(tree.root?.value, 10)
        XCTAssertTrue(tree.size == 7)
        XCTAssertTrue(tree.height() == 3)
        tree.draw()
        // tree structure changes on edit of root value
        XCTAssertEqual(tree.root?.value, 10)
        XCTAssertTrue(tree.size == 7)
        XCTAssertTrue(tree.height() == 3)
        tree[10] = 50 // edit tree root
        XCTAssertNil(tree.search(value: 10))
        XCTAssertNotNil(tree.search(value: 50))
        XCTAssertEqual(tree.root?.value, 8)
        XCTAssertTrue(tree.size == 7)
        XCTAssertTrue(tree.height() == 4)
        tree.draw()
        // insert new values to make tree unbalanced
        tree[51] = nil
        XCTAssertNotNil(tree.search(value: 51))
        XCTAssertEqual(tree.root?.value, 8)
        XCTAssertTrue(tree.size == 8)
        XCTAssertTrue(tree.height() == 5)
        tree.draw()
    }
}
