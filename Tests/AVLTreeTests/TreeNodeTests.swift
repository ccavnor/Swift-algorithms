//
//  TreeNodeTests.swift
//  
//
//  Created by Christopher Charles Cavnor on 4/28/22.
//
import XCTest
import BinarySearchTree
@testable import AVLTree


class TreeNodeTests: XCTestCase {
    var tree: AVLTree<Int>?
    var root: AVLTreeNode<Int>?
    var left: AVLTreeNode<Int>?
    var right: AVLTreeNode<Int>?

    override func setUp() {
        super.setUp()
        tree = AVLTree(value: 4)
        try! tree?.insert(node: AVLTreeNode(value: 3))
        try! tree?.insert(node: AVLTreeNode(value: 5))
        root = tree?.root as? AVLTreeNode<Int>
        left = tree?.root?.left as? AVLTreeNode<Int>
        right = tree?.root?.right as? AVLTreeNode<Int>
        tree?.draw()
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_init() {
        let bstNode = BinarySearchTreeNode(value: 3)
        let bstTree = BinarySearchTree(node: bstNode)
        let avlNode = AVLTreeNode(value: 5)
        let avlTree = AVLTree(node: avlNode)

        // BinarySearchTree inheritance
        XCTAssertTrue(bstTree is BinarySearchTree)
        XCTAssertFalse(bstTree is AVLTree)
        XCTAssertTrue(type(of: bstTree) == BinarySearchTree<Int>.self)
        XCTAssertFalse(type(of: bstTree) == AVLTree<Int>.self)

        // BinarySearchTreeNode inheritance
        XCTAssertTrue(bstNode is BinarySearchTreeNode)
        XCTAssertFalse(bstNode is AVLTreeNode)
        XCTAssertTrue(type(of: bstNode) == BinarySearchTreeNode<Int>.self)
        XCTAssertFalse(type(of: bstNode) == AVLTreeNode<Int>.self)

        // AVLTree inheritance
        XCTAssertTrue(avlTree is BinarySearchTree<Int>)
        XCTAssertTrue(avlTree is AVLTree)
        XCTAssertFalse(type(of: avlTree) == BinarySearchTree<Int>.self)
        XCTAssertTrue(type(of: avlTree) == AVLTree<Int>.self)

        // AVLTreeNode inheritance
        XCTAssertTrue(avlNode is BinarySearchTreeNode<Int>)
        XCTAssertTrue(avlNode is AVLTreeNode)
        XCTAssertFalse(type(of: avlNode) == BinarySearchTreeNode<Int>.self)
        XCTAssertTrue(type(of: avlNode) == AVLTreeNode<Int>.self)
    }

    func test_initUsingMixedNodeTypes() {
        let bstNode = BinarySearchTreeNode(value: 3)
        let avlNode = AVLTreeNode(value: 5)

        // create BST with AVL node
        let bstTree = BinarySearchTree(node: avlNode) // BST tree using AVL node
        // create AVL with BST node
        let avlTree = AVLTree(node: bstNode) // AVL tree using BST node

        // BinarySearchTree inheritance
        XCTAssertTrue(bstTree is BinarySearchTree)
        XCTAssertFalse(bstTree is AVLTree)
        XCTAssertTrue(type(of: bstTree) == BinarySearchTree<Int>.self)
        XCTAssertFalse(type(of: bstTree) == AVLTree<Int>.self)

        // BinarySearchTreeNode inheritance
        XCTAssertTrue(bstNode is BinarySearchTreeNode)
        XCTAssertFalse(bstNode is AVLTreeNode)
        XCTAssertTrue(type(of: bstNode) == BinarySearchTreeNode<Int>.self)
        XCTAssertFalse(type(of: bstNode) == AVLTreeNode<Int>.self)

        // AVLTree inheritance
        XCTAssertTrue(avlTree is BinarySearchTree<Int>)
        XCTAssertTrue(avlTree is AVLTree)
        XCTAssertFalse(type(of: avlTree) == BinarySearchTree<Int>.self)
        XCTAssertTrue(type(of: avlTree) == AVLTree<Int>.self)

        // AVLTreeNode inheritance
        XCTAssertTrue(avlNode is BinarySearchTreeNode<Int>)
        XCTAssertTrue(avlNode is AVLTreeNode)
        XCTAssertFalse(type(of: avlNode) == BinarySearchTreeNode<Int>.self)
        XCTAssertTrue(type(of: avlNode) == AVLTreeNode<Int>.self)
    }

    func testIsRoot() {
        XCTAssertTrue(self.root!.isRoot)
    }

    func testNotIsLeaf() {
        XCTAssertFalse(self.root!.isLeaf, "root node is not leaf")
    }

    func testNotIsLeftChild() {
        XCTAssertFalse(self.root!.isLeftChild, "root node is not left child")
    }

    func testNotIsRightChild() {
        XCTAssertFalse(self.root!.isRightChild, "root node is not right child")
    }

    func testIsLeftChild() {
        XCTAssertTrue(self.left!.isLeftChild)
    }

    func testIsRightChild() {
        XCTAssertTrue(self.right!.isRightChild)
    }

    func test_isLeaf() {
        XCTAssertTrue(self.left!.isLeaf)
    }

    func testHasAnyChild() {
        XCTAssertTrue(self.root!.hasAnyChild)
    }

    func testNotHasAnyChild() {
        XCTAssertFalse(self.left!.hasAnyChild)
    }

    func testHasBothChildren() {
        XCTAssertTrue(self.root!.hasBothChildren)
    }

    func testNotHasBothChildren() {
        XCTAssertFalse(self.left!.hasBothChildren)
    }

}
