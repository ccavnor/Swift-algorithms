//
//  AVLTreeTests.swift
//  
//
//  Created by Christopher Charles Cavnor on 4/28/22.
//
import XCTest
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
//    func testInsertSize() {
//        let tree = AVLTree<String>(value: "A")
//        for i in 1...5 {
//            try! tree.insert(value: String(i))
//            XCTAssertEqual(tree.size, i + 1, "Insert didn't update size correctly!")
//        }
//    }

    func testAVLTreeBalancedAutoPopulate() {
        let tree = autopopulateWithNodes(11)
        tree.draw()
        XCTAssertEqual(6, tree.root?.value)
        XCTAssertEqual(5, tree.height(node: tree.root?.left))
        XCTAssertEqual(5, tree.height(node: tree.root?.right))

        do {
            try tree.inOrderCheckBalanced(tree.root)
        } catch _ {
            XCTFail("Tree is not balanced after autopopulate")
        }
        tree.display(node: tree.root!)
    }

    func testAVLTreeBalancedInsert() {
        let tree = autopopulateWithNodes(5)

        for i in 6...10 {
            try! tree.insert(value: i)
            do {
                try tree.inOrderCheckBalanced(self.tree?.root)
            } catch _ {
                XCTFail("Tree is not balanced after inserting " + String(i))
            }
            tree.draw()
        }
    }

    // right-right rotations performed on insert
    func testRRInsertBalance() {
        let tree = AVLTree<Int>(value: 1)
        try! tree.insert(value: 2)
        try! tree.insert(value: 3)

        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(2, tree.root?.value)
        XCTAssertEqual(1, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(3, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)

        tree.draw()
    }

    // left-left rotations performed on insert
    func testLLInsertBalance() {
        let tree = AVLTree<Int>(value: 3)
        try! tree.insert(value: 2)
        try! tree.insert(value: 1)

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
        try! tree.insert(value: 10)
        try! tree.insert(value: 9)

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
        try! tree.insert(value: 4)
        try! tree.insert(value: 5)

        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(5, tree.root?.value)
        XCTAssertEqual(4, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(8, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)

        tree.draw()
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
            let tree = AVLTree<Int>(value: p[0])
            try! tree.insert(value: p[1])
            try! tree.insert(value: p[2])
            try! tree.insert(value: p[3])
            try! tree.insert(value: p[4])

            var count = tree.size
            for i in p {
                tree.remove(value: i)
                count -= 1
                XCTAssertEqual(tree.size, count, "Delete didn't update size correctly!")
            }
        }
    }

    func testDeleteExistentKey() {
        let tree = AVLTree(value: 1)
        tree.remove(value: 1)
        XCTAssertNil(tree.search(value: 1), "Key should not exist anymore")
    }

    func testDeleteNotExistentKey() {
        self.tree?.remove(value: 1056)
        XCTAssertNil(self.tree?.search(value: 1056), "Key should not exist")
    }


    // Test balance on deletions
    //-------------------------------------
    func testAVLTreeBalancedDelete() {
        let tree = autopopulateWithNodes(5)
        tree.draw()

        for i in 1...6 {
            tree.remove(value: i)
            do {
                try tree.inOrderCheckBalanced(tree.root)
            } catch _ {
                XCTFail("Tree is not balanced after deleting " + String(i))
            }
        }
        tree.draw()
        XCTAssertTrue(tree.size == 0)
        XCTAssertTrue(tree.height() == 0)
        XCTAssertNil(tree.root)
    }

    // right-right rotations performed on deletion
    func testRRDeleteBalance() {
        let tree = AVLTree<Int>(value: 1)
        try! tree.insert(value: 2)
        try! tree.insert(value: 3)
        try! tree.insert(value: 4)

        tree.remove(value: 3)
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(2, tree.root?.value)
        XCTAssertEqual(1, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(4, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)

        tree.draw()
    }

    // left-left rotations performed on deletion
    func testLLDeleteBalance() {
        let tree = AVLTree<Int>(value: 4)
        try! tree.insert(value: 3)
        try! tree.insert(value: 2)
        try! tree.insert(value: 1)

        tree.remove(value: 3)
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(2, tree.root?.value)
        XCTAssertEqual(1, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(4, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)

        tree.draw()
    }


    // right-left rotations performed on deletion
    func testRLDeleteBalance() {
        let tree = AVLTree<Int>(value: 8)
        try! tree.insert(value: 7)
        try! tree.insert(value: 10)
        try! tree.insert(value: 9)

        tree.remove(value: 7)
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(9, tree.root?.value)
        XCTAssertEqual(8, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(10, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)

        tree.draw()
    }

    // left-right rotations performed
    func testLRDeleteBalance() {
        let tree = AVLTree<Int>(value: 8)
        try! tree.insert(value: 4)
        try! tree.insert(value: 5)
        try! tree.insert(value: 9)

        tree.remove(value: 8)
        XCTAssertTrue(tree.root!.isRoot)
        XCTAssertEqual(5, tree.root?.value)
        XCTAssertEqual(4, tree.root?.left?.value)
        XCTAssertTrue(tree.root!.left!.isLeaf)
        XCTAssertEqual(9, tree.root?.right?.value)
        XCTAssertTrue(tree.root!.right!.isLeaf)

        tree.draw()
    }

    //-------------------------------------
    // Subscript access
    //-------------------------------------
    func testSubscripting() {
        // See BST subscript testing for comprehensive test. Here, we
        // only test auto balance on insert
        let tree = AVLTree(array: [10,5,20,3,8,14,25])
        tree.draw()

        // insert new values to make tree unbalanced
        tree[51] = nil
        XCTAssertNotNil(tree.search(value: 51))
        XCTAssertEqual(tree.root?.value, 10, "root changed on auto balance")
        XCTAssertTrue(tree.size == 8)
        XCTAssertTrue(tree.height() == 4, "height same after auto balance")
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
    func testSingleInsertionPerformance() {
        self.measure {
            try! self.tree?.insert(value: 1)
        }
    }

    func testMultipleInsertionsPerformance() {
        self.measure {
            let _ = autopopulateWithNodes(50)
        }
    }

    func testSearchExistentOnSmallTreePerformance() {
        let tree = AVLTree(value: 2)
        // runs 10 times by default
        self.measure {
            print(tree.search(value: 2))
        }
    }

    func testSearchExistentElementOnLargeTreePerformance() {
        let tree = autopopulateWithNodes(500)
        self.measure {
            print(tree.search(value: 400))
        }
    }
}

//extension AVLTree where T : SignedInteger {
func autopopulateWithNodes(_ count: Int) -> AVLTree<Int> {
    var val: Int = 1
    // first value is used to create tree
    let tree = AVLTree<Int>(value: val)
    // remaining values are inserted
    if count > 1 {
        for _ in 2...count {
            val = val + 1
            try? tree.insert(value: val)
        }
    }
    return tree
}
//}

//enum AVLTreeError: Error {
//    case notBalanced
//}
//
//extension AVLTree where T : SignedInteger {
//    func height(_ node: Node?) -> Int {
//        if let node = node {
//            let lHeight = height(node.left)
//            let rHeight = height(node.right)
//
//            return max(lHeight, rHeight) + 1
//        }
//        return 0
//    }

//    func inOrderCheckBalanced(_ node: Node?) throws {
//        if let node = node {
//            print("left=\(height(node.left))")
//            print("right=\(height(node.right))")
//
//            guard abs(height(node.left) - height(node.right)) <= 1 else {
//                throw AVLTreeError.notBalanced
//            }
//            try inOrderCheckBalanced(node.left)
//            try inOrderCheckBalanced(node.right)
//        }
//    }
//}

//final class AVLTreeTests: XCTestCase {
//    var tree: AVLTree<Int, String>?
//
//    override func setUp() {
//        super.setUp()
//        tree = AVLTree()
//    }
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//
//    func testAVLTreeBalancedAutoPopulate() {
//        self.tree?.autopopulateWithNodes(10)
//
//        do {
//            try self.tree?.inOrderCheckBalanced(self.tree?.root)
//        } catch _ {
//            XCTFail("Tree is not balanced after autopopulate")
//        }
//    }
//
//    func testAVLTreeBalancedInsert() {
//        self.tree?.autopopulateWithNodes(5)
//
//        for i in 6...10 {
//            self.tree?.insert(key: i)
//            do {
//                try self.tree?.inOrderCheckBalanced(self.tree?.root)
//            } catch _ {
//                XCTFail("Tree is not balanced after inserting " + String(i))
//            }
//        }
//    }
//
//    func testAVLTreeBalancedDelete() {
//        self.tree?.autopopulateWithNodes(5)
//
//        for i in 1...6 {
//            self.tree?.delete(key: i)
//            do {
//                try self.tree?.inOrderCheckBalanced(self.tree?.root)
//            } catch _ {
//                XCTFail("Tree is not balanced after deleting " + String(i))
//            }
//        }
//    }
//
//    func testEmptyInitialization() {
//        let tree = AVLTree<Int, String>()
//
//        XCTAssertEqual(tree.size, 0)
//        XCTAssertNil(tree.root)
//    }
//
//    func testSingleInsertionPerformance() {
//        self.measure {
//            self.tree?.insert(key: 5, payload: "E")
//        }
//    }
//
//    func testMultipleInsertionsPerformance() {
//        self.measure {
//            self.tree?.autopopulateWithNodes(50)
//        }
//    }
//
//    func testSearchExistentOnSmallTreePerformance() {
//        self.measure {
//            print(self.tree?.search(input: 2))
//        }
//    }
//
//    func testSearchExistentElementOnLargeTreePerformance() {
//        self.measure {
//            self.tree?.autopopulateWithNodes(500)
//            print(self.tree?.search(input: 400))
//        }
//    }
//
//    func testMinimumOnPopulatedTree() {
//        self.tree?.autopopulateWithNodes(500)
//        let min = self.tree?.root?.minimum()
//        XCTAssertNotNil(min, "Minimum function not working")
//    }
//
//    func testMinimumOnSingleTreeNode() {
//        let treeNode = TreeNode(key: 1, payload: "A")
//        let min = treeNode.minimum()
//
//        XCTAssertNotNil(min, "Minimum on single node should be returned")
//        XCTAssertEqual(min?.value, treeNode.value)
//    }
//
//    func testDeleteExistentKey() {
//        self.tree?.delete(key: 1)
//        XCTAssertNil(self.tree?.search(input: 1), "Key should not exist anymore")
//    }
//
//    func testDeleteNotExistentKey() {
//        self.tree?.delete(key: 1056)
//        XCTAssertNil(self.tree?.search(input: 1056), "Key should not exist")
//    }
//
//    func testInsertSize() {
//        let tree = AVLTree<Int, String>()
//        for i in 0...5 {
//            tree.insert(key: i, payload: "")
//            XCTAssertEqual(tree.size, i + 1, "Insert didn't update size correctly!")
//        }
//    }
//
//    func testDelete() {
//        let permutations = [
//            [5, 1, 4, 2, 3],
//            [2, 3, 1, 5, 4],
//            [4, 5, 3, 2, 1],
//            [3, 2, 5, 4, 1],
//        ]
//
//        for p in permutations {
//            let tree = AVLTree<Int, String>()
//
//            tree.insert(key: 1, payload: "five")
//            tree.insert(key: 2, payload: "four")
//            tree.insert(key: 3, payload: "three")
//            tree.insert(key: 4, payload: "two")
//            tree.insert(key: 5, payload: "one")
//
//            var count = tree.size
//            for i in p {
//                tree.delete(key: i)
//                count -= 1
//                XCTAssertEqual(tree.size, count, "Delete didn't update size correctly!")
//            }
//        }
//    }
//}
//
//extension AVLTree where Key : SignedInteger {
//    func autopopulateWithNodes(_ count: Int) {
//        var k: Key = 1
//        for _ in 0...count {
//            self.insert(key: k)
//            k = k + 1
//        }
//    }
//}
//
//enum AVLTreeError: Error {
//    case notBalanced
//}
//
//extension AVLTree where Key : SignedInteger {
//    func height(_ node: Node?) -> Int {
//        if let node = node {
//            let lHeight = height(node.left)
//            let rHeight = height(node.right)
//
//            return max(lHeight, rHeight) + 1
//        }
//        return 0
//    }
//
//    func inOrderCheckBalanced(_ node: Node?) throws {
//        if let node = node {
//            guard abs(height(node.left) - height(node.right)) <= 1 else {
//                throw AVLTreeError.notBalanced
//            }
//            try inOrderCheckBalanced(node.left)
//            try inOrderCheckBalanced(node.right)
//        }
//    }
//}

//
//class AVLTreeTests: XCTestCase {
//  var tree: AVLTree<Int, String>?
//
//    func testSwift4() {
//        // last checked with Xcode 9.0b4
//        #if swift(>=4.0)
//            print("Hello, Swift 4!")
//        #endif
//    }
//  override func setUp() {
//    super.setUp()
//
//    tree = AVLTree()
//  }
//
//  override func tearDown() {
//    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    super.tearDown()
//  }
//
//  func testAVLTreeBalancedAutoPopulate() {
//    self.tree?.autopopulateWithNodes(10)
//
//    do {
//      try self.tree?.inOrderCheckBalanced(self.tree?.root)
//    } catch _ {
//      XCTFail("Tree is not balanced after autopopulate")
//    }
//  }
//
//  func testAVLTreeBalancedInsert() {
//    self.tree?.autopopulateWithNodes(5)
//
//    for i in 6...10 {
//      self.tree?.insert(key: i)
//      do {
//        try self.tree?.inOrderCheckBalanced(self.tree?.root)
//      } catch _ {
//        XCTFail("Tree is not balanced after inserting " + String(i))
//      }
//    }
//  }
//
//  func testAVLTreeBalancedDelete() {
//    self.tree?.autopopulateWithNodes(5)
//
//    for i in 1...6 {
//      self.tree?.delete(key: i)
//      do {
//        try self.tree?.inOrderCheckBalanced(self.tree?.root)
//      } catch _ {
//        XCTFail("Tree is not balanced after deleting " + String(i))
//      }
//    }
//  }
//
//  func testEmptyInitialization() {
//    let tree = AVLTree<Int, String>()
//
//    XCTAssertEqual(tree.size, 0)
//    XCTAssertNil(tree.root)
//  }
//
//  func testSingleInsertionPerformance() {
//    self.measure {
//      self.tree?.insert(key: 5, payload: "E")
//    }
//  }
//
//  func testMultipleInsertionsPerformance() {
//    self.measure {
//      self.tree?.autopopulateWithNodes(50)
//    }
//  }
//
//  func testSearchExistentOnSmallTreePerformance() {
//    self.measure {
//      print(self.tree?.search(input: 2))
//    }
//  }
//
//  func testSearchExistentElementOnLargeTreePerformance() {
//    self.measure {
//      self.tree?.autopopulateWithNodes(500)
//      print(self.tree?.search(input: 400))
//    }
//  }
//
//  func testMinimumOnPopulatedTree() {
//    self.tree?.autopopulateWithNodes(500)
//    let min = self.tree?.root?.minimum()
//    XCTAssertNotNil(min, "Minimum function not working")
//  }
//
//  func testMinimumOnSingleTreeNode() {
//    let treeNode = TreeNode(key: 1, payload: "A")
//    let min = treeNode.minimum()
//
//    XCTAssertNotNil(min, "Minimum on single node should be returned")
//    XCTAssertEqual(min?.payload, treeNode.payload)
//  }
//
//  func testDeleteExistentKey() {
//    self.tree?.delete(key: 1)
//    XCTAssertNil(self.tree?.search(input: 1), "Key should not exist anymore")
//  }
//
//  func testDeleteNotExistentKey() {
//    self.tree?.delete(key: 1056)
//    XCTAssertNil(self.tree?.search(input: 1056), "Key should not exist")
//  }
//
//  func testInsertSize() {
//    let tree = AVLTree<Int, String>()
//    for i in 0...5 {
//      tree.insert(key: i, payload: "")
//      XCTAssertEqual(tree.size, i + 1, "Insert didn't update size correctly!")
//    }
//  }
//
//  func testDelete() {
//    let permutations = [
//      [5, 1, 4, 2, 3],
//      [2, 3, 1, 5, 4],
//      [4, 5, 3, 2, 1],
//      [3, 2, 5, 4, 1],
//    ]
//
//    for p in permutations {
//      let tree = AVLTree<Int, String>()
//
//      tree.insert(key: 1, payload: "five")
//      tree.insert(key: 2, payload: "four")
//      tree.insert(key: 3, payload: "three")
//      tree.insert(key: 4, payload: "two")
//      tree.insert(key: 5, payload: "one")
//
//      var count = tree.size
//      for i in p {
//        tree.delete(key: i)
//        count -= 1
//        XCTAssertEqual(tree.size, count, "Delete didn't update size correctly!")
//      }
//    }
//  }
//}
//
//extension AVLTree where Key : SignedInteger {
//  func autopopulateWithNodes(_ count: Int) {
//    var k: Key = 1
//    for _ in 0...count {
//      self.insert(key: k)
//      k = k + 1
//    }
//  }
//}
//
//enum AVLTreeError: Error {
//  case notBalanced
//}
//
//extension AVLTree where Key : SignedInteger {
//  func height(_ node: Node?) -> Int {
//    if let node = node {
//      let lHeight = height(node.leftChild)
//      let rHeight = height(node.rightChild)
//
//      return max(lHeight, rHeight) + 1
//    }
//    return 0
//  }
//
//  func inOrderCheckBalanced(_ node: Node?) throws {
//    if let node = node {
//      guard abs(height(node.leftChild) - height(node.rightChild)) <= 1 else {
//        throw AVLTreeError.notBalanced
//      }
//      try inOrderCheckBalanced(node.leftChild)
//      try inOrderCheckBalanced(node.rightChild)
//    }
//  }
//}
