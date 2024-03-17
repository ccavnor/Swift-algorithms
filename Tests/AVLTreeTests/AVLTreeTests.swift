//
//  AVLTreeTests.swift
//  
//
//  Created by Christopher Charles Cavnor on 4/28/22.
//
import XCTest
import TreeProtocol
import BinarySearchTree

@testable import AVLTree

final class AVLTreeTests: XCTestCase {
    var tree: AVLTree<Int>?

    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleTree() {
        let tree: AVLTree<Int> = autopopulateWithNodes(3)
        XCTAssertTrue(tree.size == 3)
        XCTAssertEqual(2, tree.root?.value)
        XCTAssertEqual(1, tree.root?.left?.value)
        XCTAssertEqual(3, tree.root?.right?.value)
        tree.draw()

        // test with strings
        let tree_string = AVLTree<String>(value: "a")
        try! tree_string.insert(node: AVLTreeNode<String>(value: "b"))
        try! tree_string.insert(node: AVLTreeNode<String>(value: "c"))

        XCTAssertTrue(tree_string.size == 3)
        XCTAssertEqual("b", tree_string.root?.value)
        XCTAssertEqual("a", tree_string.root?.left?.value)
        XCTAssertEqual("c", tree_string.root?.right?.value)

        tree_string.draw()
    }

    //------------------------
    // Insertions
    //------------------------
    func testDuplicatesIgnored() {
        let tree: AVLTree<Int> = autopopulateWithNodes(3)
        try! tree.insert(node: AVLTreeNode<Int>(value: 1)) // duplicate value
        XCTAssertTrue(tree.size == 3)
        XCTAssertEqual(2, tree.root?.value)
        XCTAssertEqual(1, tree.root?.left?.value)
        XCTAssertEqual(3, tree.root?.right?.value)
    }

    func testAVLTreeBalancedAutoPopulate() {
        let tree: AVLTree<Int> = autopopulateWithNodes(5)
        XCTAssertTrue(tree is BinarySearchTree<Int>, "AVLTree inherits from BST")
        XCTAssertTrue(tree is AVLTree<Int>)

        // inOrderCheckBalanced throws whenever the difference in heights of tree hemispheres is >1
        do {
            try tree.inOrderCheckBalanced(tree.root as? AVLTreeNode<Int>)
        } catch _ {
            XCTFail("Tree is not balanced after autopopulate")
        }
        tree.draw()
        // every new node now causes an imbalance
        for i in 6...10 {
            let curr = AVLTreeNode(value: i)
            try! tree.insert(node: curr)
            do {
                XCTExpectFailure("Tree is not balanced after inserting " + String(i))
                try tree.inOrderCheckBalanced(tree.root as? AVLTreeNode<Int>)
            } catch _ {
                XCTFail("Tree is not balanced after inserting " + String(i))
            }
        }
    }

    func testRootSetAfterBalance() {
        let tree: AVLTree<Int> = autopopulateWithNodes(11) // enough nodes to ensure balancing
        // make sure that only one node is set as root after insertions and rotations
        XCTAssertEqual(6, tree.root?.value)
        // During balancings, tree roots are: 2, 3, 4, 5, 6
        for i in 1...tree.size {
            let curr = tree.search(value: i)
            if (curr?.value == 6) {
                XCTAssertTrue(curr!.isRoot)
            } else {
                XCTAssertFalse(curr!.isRoot)
            }
        }
        tree.draw()
    }

    func testAVLTreeBalancedInsert() throws {
        let tree: AVLTree<Int> = autopopulateWithNodes(5)
        tree.draw()

        for i in 6...10 {
            let curr = AVLTreeNode(value: i)
            try! tree.insert(node: curr)

            do {
                XCTExpectFailure("Tree is not balanced after inserting " + String(i))
                try tree.inOrderCheckBalanced(tree.root as? AVLTreeNode<Int>)
            } catch _ {
                XCTFail("Tree is not balanced after inserting " + String(i))
            }
            tree.draw()
        }
    }

    func testHeights() {
        let tree: AVLTree<Int> = AVLTree(value: 1)
        XCTAssertTrue(tree.root?.height == 1)

        // all newly added nodes have height=1
        for i in 2...7 {
            let curr = AVLTreeNode(value: i)
            try! tree.insert(node: curr)
            XCTAssertTrue(curr.height == 1)
        }
        tree.draw()
        //tree.display(node: tree.root!)
        // check final heights
        let root = tree.root!
        XCTAssertTrue(root.height == 4) // node value 4
        XCTAssertTrue(root.left?.height == 3) // node value 3
        XCTAssertTrue(root.right?.height == 3) // node value 5
        XCTAssertTrue(root.left?.left?.height == 2) // node value 2
        XCTAssertTrue(root.right?.right?.height == 2) // node value 6
        XCTAssertTrue(root.left?.left?.left?.height == 1) // node value 1
        XCTAssertTrue(root.right?.right?.right?.height == 1) // node value 7
    }

    func testBalanceFuncs() {
        // insert root
        let tree = AVLTree<Int>(value: 5)
        do {
            try tree.inOrderCheckBalanced(tree.root as? AVLTreeNode<Int>)
        } catch _ {
            XCTFail("Tree is not balanced after inserting 5")
        }
        // insert node left
        let node1 = AVLTreeNode(value: 2)
        try! tree.insert(node: node1)
        do {
            try tree.inOrderCheckBalanced(tree.root as? AVLTreeNode<Int>)
        } catch _ {
            XCTFail("Tree is not balanced after inserting 2")
        }
        // insert node right
        let node2 = AVLTreeNode(value: 7)
        try! tree.insert(node: node2)
        do {
            try tree.inOrderCheckBalanced(tree.root as? AVLTreeNode<Int>)
        } catch _ {
            XCTFail("Tree is not balanced after inserting 7")
        }
        // insert another node right
        let node3 = AVLTreeNode(value: 8)
        try! tree.insert(node: node3)
        do {
            try tree.inOrderCheckBalanced(tree.root as? AVLTreeNode<Int>)
        } catch _ {
            XCTFail("Tree is not balanced after inserting 8")
        }
        // insert another node right to cause rebalance
        let node4 = AVLTreeNode(value: 9)
        try! tree.insert(node: node4)
        do {
            try tree.inOrderCheckBalanced(tree.root as? AVLTreeNode<Int>)
        } catch _ {
            XCTFail("Tree is not balanced after inserting 9")
        }

        tree.draw()
    }

    // See: https://stackoverflow.com/questions/3955680/how-to-check-if-my-avl-tree-implementation-is-correct
    // for test cases

    // left-left (1L) rotation performed on insert
    // 👍
    func testLLInsertBalance() {
        let tree = AVLTree<Int>(value: 1)
        try! tree.insert(node: AVLTreeNode(value: 2))
        try! tree.insert(node: AVLTreeNode(value: 3))
        tree.draw()

        // test values
        XCTAssertEqual(2, tree.root?.value)
        XCTAssertEqual(1, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(3, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test parents after balance
        XCTAssertNil(tree.root?.parent)
        XCTAssertTrue(tree.root?.left?.parent?.value == 2)
        XCTAssertTrue(tree.root?.right?.parent?.value == 2)
        // test root
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertFalse(tree.root!.left!.isRoot)
        XCTAssertFalse(tree.root!.right!.isRoot)
    }

    // right-right (1R) rotation performed on insert
    // 👍
    func testRRInsertBalance() {
        let tree = AVLTree<Int>(value: 3)
        try! tree.insert(node: AVLTreeNode(value: 2))
        try! tree.insert(node: AVLTreeNode(value: 1))
        tree.draw() // (1[1]? <- 2[2] -> 3[1]?)

        // test values
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(2, tree.root?.value)
        XCTAssertEqual(1, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(3, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test parents after balance
        XCTAssertNil(tree.root?.parent)
        XCTAssertTrue(tree.root?.left?.parent?.value == 2)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertTrue(tree.root?.right?.parent?.value == 2)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test root
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertFalse(tree.root!.left!.isRoot)
        XCTAssertFalse(tree.root!.right!.isRoot)
    }

    // right-left (2L) rotations performed on insert
    // 👍
    func testRLInsertBalance() {
        let tree = AVLTree<Int>(value: 6)
        try! tree.insert(node: AVLTreeNode(value: 8))
        try! tree.insert(node: AVLTreeNode(value: 7))
        tree.draw()

        // test values
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(7, tree.root?.value)
        XCTAssertEqual(6, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(8, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test parents after balance
        XCTAssertNil(tree.root?.parent)
        XCTAssertTrue(tree.root?.left?.parent?.value == 7)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertTrue(tree.root?.right?.parent?.value == 7)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test root
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertFalse(tree.root!.left!.isRoot)
        XCTAssertFalse(tree.root!.right!.isRoot)
    }

    // left-right (2R) rotations performed
    // 👍
    func testLRInsertBalance() {
        let tree = AVLTree<Int>(value: 8)
        try! tree.insert(node: AVLTreeNode(value: 4))
        try! tree.insert(node: AVLTreeNode(value: 5))
        tree.draw()

        // test values
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(5, tree.root?.value)
        XCTAssertEqual(4, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(8, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test parents after balance
        XCTAssertNil(tree.root?.parent)
        XCTAssertTrue(tree.root?.left?.parent?.value == 5)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertTrue(tree.root?.right?.parent?.value == 5)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test root
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertFalse(tree.root!.left!.isRoot)
        XCTAssertFalse(tree.root!.right!.isRoot)
    }

    //------------------------
    // Search
    //------------------------
    func testSearch() {
        let tree = AVLTree(array: [3, 1, 2, 5, 4])
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


    //------------------------
    // Deletions
    //------------------------
    func testDelete() {
        let permutations = [
            [5, 1, 4, 2, 3],
            [2, 3, 1, 5, 4],
            [4, 5, 3, 2, 1],
            [3, 2, 5, 4, 1],
        ]

        for p in permutations {
            print("Permutation is \(p)")
            let tree = AVLTree<Int>(value: p[0])
            try! tree.insert(node: AVLTreeNode(value: p[1]))
            try! tree.insert(node: AVLTreeNode(value: p[2]))
            try! tree.insert(node: AVLTreeNode(value: p[3]))
            try! tree.insert(node: AVLTreeNode(value: p[4]))

            tree.draw()
            var count = tree.size
            for i in p {
                tree.remove(value: i)
                count -= 1
                XCTAssertEqual(tree.size, count, "Delete didn't update size correctly!")
            }
            tree.draw()
        }
    }

    func testDeleteExistentKey() {
        let tree = AVLTree(value: 1)
        _ = tree.remove(value: 1)
        XCTAssertNil(tree.search(value: 1), "Key should not exist anymore")
    }

    func testDeleteNotExistentKey() {
        _ = self.tree?.remove(value: 1056)
        XCTAssertNil(self.tree?.search(value: 1056), "Key should not exist")
    }


    // Test balance on deletions
    //-------------------------------------
    func testAVLTreeBalancedDelete() {
        let tree: AVLTree<Int> = autopopulateWithNodes(5)

        // tree root will be 3,4,5 during deletions and rebalancing
        for i in 1...5 {
            tree.draw()
            tree.remove(value: i)
            if tree.size > 0 {
                XCTAssertTrue(tree.root!.isRoot) // tree root node is marked as root
            }
            do {
                try tree.inOrderCheckBalanced(tree.root as? AVLTreeNode<Int>)
            } catch _ {
                XCTFail("Tree is not balanced after deleting " + String(i))
            }
        }
        tree.draw()
        XCTAssertTrue(tree.size == 0)
        XCTAssertTrue(tree.height() == 0)
        XCTAssertNil(tree.root)
    }

    // See: https://stackoverflow.com/questions/3955680/how-to-check-if-my-avl-tree-implementation-is-correct
    // for test cases

    //--------------------------------------
    // deletion and rotation of inner nodes
    //--------------------------------------

    // right-right rotations performed on deletion.
    // conditions: lrDifference == 2, leftChild.balanceFactor != -1
    // 👍
    func testRRDeleteBalance() {
        let tree = AVLTree<Int>(value: 1)
        try! tree.insert(node: AVLTreeNode(value: 2))
        try! tree.insert(node: AVLTreeNode(value: 3))
        try! tree.insert(node: AVLTreeNode(value: 4))
        try! tree.insert(node: AVLTreeNode(value: 5))

        tree.draw()
        let removed_5 = tree.remove(value: 5)
        let removed_4 = tree.remove(value: 4)
        tree.draw()

        // ensure that deleted nodes have no connections to tree
        XCTAssertFalse(removed_4!.hasAnyChild)
        XCTAssertNil(removed_4!.parent)
        XCTAssertFalse(removed_5!.hasAnyChild)
        XCTAssertNil(removed_5!.parent)

        // assert deleted values are not in tree
        XCTAssertNil(tree.search(value: 5))
        XCTAssertNil(tree.search(value: 4))
        // test values
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(2, tree.root?.value)
        XCTAssertEqual(1, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test parents after balance
        XCTAssertNil(tree.root?.parent)
        XCTAssertTrue(tree.root?.left?.parent?.value == 2)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertTrue(tree.root?.right?.parent?.value == 2)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test root
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertFalse(tree.root!.left!.isRoot)
        XCTAssertFalse(tree.root!.right!.isRoot)
    }

    // left-right rotations performed
    // conditions: lrDifference == 2, leftChild.balanceFactor == -1
    // 👍
    func testLRDeleteBalance() {
        let tree = AVLTree<Int>(value: 5)
        try! tree.insert(node: AVLTreeNode(value: 2))
        try! tree.insert(node: AVLTreeNode(value: 4))
        try! tree.insert(node: AVLTreeNode(value: 3))

        tree.draw()
        tree.remove(value: 5)
        tree.draw()

        // assert deleted values are not in tree
        XCTAssertNil(tree.search(value: 5))
        // test values
        XCTAssertTrue(tree.nodeCount == 3)
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(3, tree.root?.value)
        XCTAssertEqual(2, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(4, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test parents after balance
        XCTAssertNil(tree.root?.parent)
        XCTAssertTrue(tree.root?.left?.parent?.value == 3)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertTrue(tree.root?.right?.parent?.value == 3)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test root
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertFalse(tree.root!.left!.isRoot)
        XCTAssertFalse(tree.root!.right!.isRoot)
    }

    // left-left rotations performed on deletion
    // conditions: lrDifference == -2, rightChild.balanceFactor != 1
    // 👍
    func testLLDeleteBalance() {
        let tree = AVLTree<Int>(value: 5)
        try! tree.insert(node: AVLTreeNode(value: 4))
        try! tree.insert(node: AVLTreeNode(value: 3))
        try! tree.insert(node: AVLTreeNode(value: 2))
        try! tree.insert(node: AVLTreeNode(value: 1))

        tree.draw()
        _ = tree.remove(value: 1)
        _ = tree.remove(value: 2)
        tree.draw()

        // assert deleted values are not in tree
        XCTAssertNil(tree.search(value: 1))
        XCTAssertNil(tree.search(value: 2))
        // test values
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(4, tree.root?.value)
        XCTAssertEqual(3, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(5, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test parents after balance
        XCTAssertNil(tree.root?.parent)
        XCTAssertTrue(tree.root?.left?.parent?.value == 4)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertTrue(tree.root?.right?.parent?.value == 4)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test root
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertFalse(tree.root!.left!.isRoot)
        XCTAssertFalse(tree.root!.right!.isRoot)
    }

    // right-left rotations performed on deletion
    // conditions: lrDifference == -2, rightChild.balanceFactor == 1
    // 👍
    func testRLDeleteBalance() {
        let tree = AVLTree<Int>(value: 8)
        try! tree.insert(node: AVLTreeNode(value: 6))
        try! tree.insert(node: AVLTreeNode(value: 7))
        try! tree.insert(node: AVLTreeNode(value: 10))
        try! tree.insert(node: AVLTreeNode(value: 9))

        tree.draw()
        _ = tree.remove(value: 7)
        _ = tree.remove(value: 6)
        tree.draw()

        // assert deleted values are not in tree
        XCTAssertNil(tree.search(value: 6))
        XCTAssertNil(tree.search(value: 7))
        // test values
        XCTAssertTrue(tree.nodeCount == 3)
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(9, tree.root?.value)
        XCTAssertEqual(8, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(10, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test parents after balance
        XCTAssertNil(tree.root?.parent)
        XCTAssertTrue(tree.root?.left?.parent?.value == 9)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertTrue(tree.root?.right?.parent?.value == 9)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test root
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertFalse(tree.root!.left!.isRoot)
        XCTAssertFalse(tree.root!.right!.isRoot)
    }

    //--------------------------------------
    // deletion and rotation of leaf nodes
    //--------------------------------------

    // See: https://stackoverflow.com/questions/3955680/how-to-check-if-my-avl-tree-implementation-is-correct
    // for test cases

    // Regression test - there was a bug in AVL rotation where deleting a leaf (when triggering rebalance)
    // implicitly deletes the leaf's parent node as well.
    // 👍
    func testDeleteLeaf_RL_rotation() {
        let tree = AVLTree<Int>(array: [5,4,7,6])
        XCTAssertTrue(tree.size == 4)
        XCTAssertTrue(tree.toArray().count == 4)

        // node=4 before deletion
        let node_4 = tree.search(value: 4)
        XCTAssertFalse(node_4!.hasLeftChild)
        XCTAssertFalse(node_4!.hasRightChild)
        XCTAssertTrue(node_4!.isLeftChild)
        XCTAssertFalse(node_4!.isRightChild)
        XCTAssertNotNil(node_4!.parent)

        tree.draw()
        let removed_4 = tree.remove(value: 4)
        tree.draw()
        XCTAssertTrue(tree.size == 3)
        XCTAssertTrue(tree.toArray().count == 3)
        XCTAssertEqual(tree.size, tree.toArray().count, "tree size does not match node count")

        // ensure that deleted nodes have no connections to tree
        XCTAssertEqual(4, removed_4?.value)
        XCTAssertFalse(removed_4!.hasLeftChild)
        XCTAssertFalse(removed_4!.hasRightChild)
        XCTAssertFalse(removed_4!.isLeftChild)
        XCTAssertFalse(removed_4!.isRightChild)
        XCTAssertNil(removed_4!.parent)
        // assert deleted values are not searchable
        XCTAssertNil(tree.search(value: 4))
        // test values
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(6, tree.root?.value)
        XCTAssertEqual(5, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(7, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test parents after balance
        XCTAssertNil(tree.root?.parent)
        XCTAssertTrue(tree.root?.left?.parent?.value == 6)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertTrue(tree.root?.right?.parent?.value == 6)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test root
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertFalse(tree.root!.left!.isRoot)
        XCTAssertFalse(tree.root!.right!.isRoot)
    }

    // Regression test - there was a bug in AVL rotation where deleting a leaf (when triggering rebalance)
    // implicitly deletes the leaf's parent node as well.
    // 👍
    func testDeleteLeaf_RR_rotation() {
        let tree = AVLTree<Int>(array: [-1,-2,-3,0,1,2])
        XCTAssertTrue(tree.size == 6)
        XCTAssertTrue(tree.toArray().count == 6)

        tree.draw()
        let removed_1 = tree.remove(value: 1)
        _ = tree.remove(value: 2)
        _ = tree.remove(value: 0)
        tree.draw()
        XCTAssertTrue(tree.size == 3)
        XCTAssertTrue(tree.toArray().count == 3)
        XCTAssertEqual(tree.size, tree.toArray().count, "tree size does not match node count")

        // ensure that deleted nodes have no connections to tree
        XCTAssertFalse(removed_1!.hasAnyChild)
        XCTAssertFalse(removed_1!.isLeftChild)
        XCTAssertFalse(removed_1!.isRightChild)
        XCTAssertNil(removed_1!.parent)
        // assert deleted values are not searchable
        XCTAssertNil(tree.search(value: 0))
        XCTAssertNil(tree.search(value: 1))
        XCTAssertNil(tree.search(value: 2))
        // test values
        XCTAssertTrue(tree.nodeCount == 3)
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(-2, tree.root?.value)
        XCTAssertEqual(-3, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(-1, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test parents after balance
        XCTAssertNil(tree.root?.parent)
        XCTAssertTrue(tree.root?.left?.parent?.value == -2)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertTrue(tree.root?.right?.parent?.value == -2)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test root
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertFalse(tree.root!.left!.isRoot)
        XCTAssertFalse(tree.root!.right!.isRoot)
    }

    // Regression test - there was a bug in AVL rotation where deleting a leaf (when triggering rebalance)
    // implicitly deletes the leaf's parent node as well.
    // 👍
    func testDeleteLeaf_LR_rotation() {
        //let tree = AVLTree<Int>(array: [8,5,6,10])
        let tree = AVLTree<Int>(array: [7,12,5,6])
        XCTAssertTrue(tree.size == 4)
        XCTAssertTrue(tree.toArray().count == 4)
        tree.draw()
        _ = tree.remove(value: 12)
        tree.draw()
        XCTAssertTrue(tree.size == 3)
        XCTAssertTrue(tree.toArray().count == 3)
        XCTAssertEqual(tree.size, tree.toArray().count, "tree size does not match node count")

        // assert deleted values are not in tree
        XCTAssertNil(tree.search(value: 12))
        // test values
        XCTAssertTrue(tree.nodeCount == 3)
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(6, tree.root?.value)
        XCTAssertEqual(5, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(7, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test parents after balance
        XCTAssertNil(tree.root?.parent)
        XCTAssertTrue(tree.root?.left?.parent?.value == 6)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertTrue(tree.root?.right?.parent?.value == 6)
        XCTAssertTrue(tree.root!.right!.isLeaf)
        // test root
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertFalse(tree.root!.left!.isRoot)
        XCTAssertFalse(tree.root!.right!.isRoot)
    }

    // Regression test - there was a bug in AVL rotation where deleting a leaf (when triggering rebalance)
    // implicitly deletes the leaf's parent node as well.
    // 👍
    func testDeleteLeaf_LL_rotation() {
        let tree = AVLTree<Int>(array: [-2,-3,0,2,5,7])
        XCTAssertTrue(tree.size == 6)
        XCTAssertTrue(tree.toArray().count == 6)
        tree.draw()
        _ = tree.remove(value: -2)
        tree.draw()
        XCTAssertTrue(tree.size == 5)
        XCTAssertTrue(tree.toArray().count == 5)
        XCTAssertEqual(tree.size, tree.toArray().count, "tree size does not match node count")

        // assert deleted values are not in tree
        XCTAssertNil(tree.search(value: -2))
        // test values
        XCTAssertTrue(tree.nodeCount == 5)
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(2, tree.root?.value)
        XCTAssertEqual(0, tree.root?.left?.value)
        XCTAssertEqual(-3, tree.root?.left?.left?.value)
        XCTAssertTrue(tree.root!.left!.left!.isLeaf)
        XCTAssertEqual(5, tree.root?.right?.value)
        XCTAssertEqual(7, tree.root?.right?.right?.value)
        XCTAssertTrue(tree.root!.right!.right!.isLeaf)
        // test parents after balance
        XCTAssertNil(tree.root?.parent)
        XCTAssertTrue(tree.root?.left?.parent?.value == 2)
        XCTAssertTrue(tree.root?.left?.left?.parent?.value == 0)
        XCTAssertTrue(tree.root?.right?.parent?.value == 2)
        XCTAssertTrue(tree.root?.right?.right?.parent?.value == 5)
        // test root
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertFalse(tree.root!.left!.isRoot)
        XCTAssertFalse(tree.root!.right!.isRoot)
    }


    //-------------------------------------
    // Subscript access
    //-------------------------------------
    func testSubscripting() {
        let tree = AVLTree(array: [10,5,20,3,8,14,25])
        tree.draw()

        // get values
        XCTAssertEqual(tree[10], 10)
        XCTAssertEqual(tree[14], 14)
        XCTAssertEqual(tree[25], 25)
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
        XCTAssertEqual(tree.root?.value, 50)
        XCTAssertTrue(tree.size == 7)
        XCTAssertTrue(tree.height() == 3)
        tree.draw()
        // delete values
        tree[25] = nil
        XCTAssertNil(tree.search(value: 25))
        XCTAssertTrue(tree.size == 7)
        // insert new value to make tree unbalanced
        tree[51] = 51
        XCTAssertNotNil(tree.search(value: 51))
        XCTAssertEqual(tree.root?.value, 50)
        XCTAssertTrue(tree.size == 8)
        XCTAssertTrue(tree.height() == 4)
        tree.draw()
    }


    //-------------------------------------
    // Performance Tests
    //-------------------------------------
//    func testSingleInsertionPerformance() {
//        self.measure {
//            try! self.tree?.insert(value: 1)
//        }
//    }
//
//    func testMultipleInsertionsPerformance() {
//        self.measure {
//            let _ = autopopulateWithNodes(50)
//        }
//    }
//
//    func testSearchExistentOnSmallTreePerformance() {
//        let tree = AVLTree(value: 2)
//        // runs 10 times by default
//        self.measure {
//            print(tree.search(value: 2)!)
//        }
//    }
//
//    func testSearchExistentElementOnLargeTreePerformance() {
//        let tree = autopopulateWithNodes(500)
//        self.measure {
//            print(tree.search(value: 400)!)
//        }
//    }
}

func autopopulateWithNodes(_ count: Int) -> AVLTree<Int> {
    var val = 1
    // first value is used to create tree
    let tree = AVLTree<Int>(value: val)
    // remaining values are inserted
    if count > 1 {
        for _ in 2...count {
            val = val + 1
            _ = try? tree.insert(node: AVLTreeNode(value: val))
        }
    }
    return tree
}
