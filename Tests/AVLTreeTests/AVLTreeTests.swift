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

    //------------------------
    // Insertions
    //------------------------
    func testAVLTreeBalancedAutoPopulate() {
        let tree: AVLTree<Int> = autopopulateWithNodes(11)
        XCTAssertTrue(tree is BinarySearchTree<Int>, "AVLTree inherits from BST")
        XCTAssertTrue(tree is AVLTree<Int>)

        tree.balance()
        tree.draw()
        XCTAssertEqual(6, tree.root?.value)
        XCTAssertEqual(5, tree.height(node: tree.root?.left))
        XCTAssertEqual(5, tree.height(node: tree.root?.right))

        do {
            try tree.inOrderCheckBalanced(tree.root as? AVLTreeNode<Int>)
        } catch _ {
            XCTFail("Tree is not balanced after autopopulate")
        }
        //tree.display(node: tree.root!)
    }

    func testAVLTreeBalancedInsert() {
        let tree: AVLTree<Int> = autopopulateWithNodes(5)

        for i in 6...10 {
            try! tree.insert(node: AVLTreeNode(value: i))
            do {
                try tree.inOrderCheckBalanced(tree.root as? AVLTreeNode<Int>)
            } catch _ {
                XCTFail("Tree is not balanced after inserting " + String(i))
            }
            tree.draw()
        }
    }

    // left-left rotation performed on insert
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
    }

    // right-right rotation performed on insert
    func testRRInsertBalance() {
        let tree = AVLTree<Int>(value: 3)
        try! tree.insert(node: AVLTreeNode(value: 2))
        try! tree.insert(node: AVLTreeNode(value: 1))

        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(2, tree.root?.value)
        XCTAssertEqual(1, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(3, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)

        tree.draw()
    }

    // right-left rotations performed on insert
    func testRLInsertBalance() {
        let tree = AVLTree<Int>(value: 8)
        try! tree.insert(node: AVLTreeNode(value: 10))
        try! tree.insert(node: AVLTreeNode(value: 9))

        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(9, tree.root?.value)
        XCTAssertEqual(8, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(10, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)

        tree.draw()
    }

    // left-right rotations performed
    func testLRInsertBalance() {
        let tree = AVLTree<Int>(value: 8)
        try! tree.insert(node: AVLTreeNode(value: 4))
        try! tree.insert(node: AVLTreeNode(value: 5))

        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(5, tree.root?.value)
        XCTAssertEqual(4, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(8, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)

        tree.draw()
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

        tree.draw()

        for i in 1...6 {
            tree.remove(value: i)
            do {
                // downcast tree to AVLTree
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
        _ = tree.remove(value: 5)
        _ = tree.remove(value: 4)
        tree.draw()
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(2, tree.root?.value)
        XCTAssertEqual(1, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertTrue(tree.root!.right!.isLeaf)
    }

    // left-right rotations performed
    // conditions: lrDifference == 2, leftChild.balanceFactor == -1
    // 👍
    func testLRDeleteBalance() {
        let tree = AVLTree<Int>(value: 3)
        try! tree.insert(node: AVLTreeNode(value: 2))
        try! tree.insert(node: AVLTreeNode(value: 5))
        try! tree.insert(node: AVLTreeNode(value: 4))
        try! tree.insert(node: AVLTreeNode(value: 10))
        try! tree.insert(node: AVLTreeNode(value: 12))

        tree.draw()
        tree.remove(value: 2)
        tree.remove(value: 10)
        tree.remove(value: 12)
        tree.draw()

        XCTAssertTrue(tree.nodeCount == 3)
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(4, tree.root?.value)
        XCTAssertEqual(3, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(5, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)
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
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(4, tree.root?.value)
        XCTAssertEqual(3, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(5, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)
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

        XCTAssertTrue(tree.nodeCount == 3)
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(9, tree.root?.value)
        XCTAssertEqual(8, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(10, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)
    }

    // See: https://stackoverflow.com/questions/3955680/how-to-check-if-my-avl-tree-implementation-is-correct
    // for test cases

    // Regression test - there was a bug in AVL rotation where deleting a leaf (when triggering rebalance)
    // implicitly deletes the leaf's parent node as well.
    // 👍
    func testDeleteLeaf_RL_rotation() {
        let tree = AVLTree<Int>(array: [5,4,7,6])
        XCTAssertTrue(tree.size == 4)
        XCTAssertTrue(tree.toArray().count == 4)

        tree.draw()
        _ = tree.remove(value: 4)
        tree.draw()
        XCTAssertTrue(tree.size == 3)
        XCTAssertTrue(tree.toArray().count == 3)
        XCTAssertEqual(tree.size, tree.toArray().count, "tree size does not match node count")
    }

    // Regression test - there was a bug in AVL rotation where deleting a leaf (when triggering rebalance)
    // implicitly deletes the leaf's parent node as well.
    // 👍
    func testDeleteLeaf_RR_rotation() {
        let tree = AVLTree<Int>(array: [-1,-2,-3,0,1,2])
        XCTAssertTrue(tree.size == 6)
        XCTAssertTrue(tree.toArray().count == 6)

        tree.draw()
        _ = tree.remove(value: 1)
        _ = tree.remove(value: 2)
        _ = tree.remove(value: 0)
        tree.draw()
        XCTAssertTrue(tree.size == 3)
        XCTAssertTrue(tree.toArray().count == 3)
        XCTAssertEqual(tree.size, tree.toArray().count, "tree size does not match node count")
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
        XCTAssertEqual(tree.root?.value, 20)
        XCTAssertTrue(tree.size == 8)
        XCTAssertTrue(tree.height() == 4)
        tree.draw()
    }


    //-------------------------------------
    // Misc Tests
    //-------------------------------------
    func testMinimumOnPopulatedTree() {
        let tree = autopopulateWithNodes(500)
        let min = tree.minimum()
        XCTAssertNotNil(min, "Minimum function not working")
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
