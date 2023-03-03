//
//  TreeProtocol.swift
//  
//
//  Created by Christopher Charles Cavnor on 1/10/23.
//

// MARK: Errors
public enum TreeError: Error {
    case notBalanced
    case invalidTree
    case invalidInterval
}

public protocol TreeProtocol {
    // MARK: - Nodes
    associatedtype NodeType: TreeNodeProtocol
    var root: NodeType? { get set }

    // MARK: - Adding items
    @discardableResult func insert(value: NodeType.ValueType) throws -> Self

    // MARK: - Deleting items
    @discardableResult func remove(value: NodeType.ValueType) -> Self

    // MARK: - Searching
    func search(value: NodeType.ValueType) -> NodeType?
    func contains(value: NodeType.ValueType) -> Bool
    func minimum() -> NodeType?
    func maximum() -> NodeType?
    func predecessor(value: NodeType.ValueType) -> NodeType.ValueType?
    func successor(value: NodeType.ValueType) -> NodeType.ValueType?

    // MARK: - Tree information
    func height() -> Int // distance from root to the lowest leaf
    func height(node: NodeType?) -> Int // distance from given node to the lowest leaf
    var size: Int { get }  // number of nodes in tree
    func inLeftTree(value: NodeType.ValueType) -> Bool
    func inRightTree(value: NodeType.ValueType) -> Bool

    // MARK: - Traversal
    func traverseInOrder(completion: (NodeType.ValueType) -> Void)
    func traversePreOrder(completion: (NodeType.ValueType) -> Void)
    func traversePostOrder(completion: (NodeType.ValueType) -> Void)
    func map(_ formula: (NodeType.ValueType) -> NodeType.ValueType) -> [NodeType.ValueType]

    // MARK: - output
    func toArray() -> [NodeType.ValueType]
    func draw()
}

public protocol TreeNodeProtocol: Comparable & Equatable {
    // MARK: - Node value
    associatedtype ValueType
    associatedtype NodeType: TreeNodeProtocol
    var value: ValueType { get set }

    // MARK: - Tree structure
    var left: NodeType? { get set }
    var right: NodeType? { get set }
    var parent: NodeType? { get set }

    // MARK: - Tree information
    var isRoot: Bool { get }
    var isLeaf: Bool { get }
    var isLeftChild: Bool { get }
    var isRightChild: Bool { get }
    var hasLeftChild: Bool { get }
    var hasRightChild: Bool { get }
    var hasAnyChild: Bool { get }
    var hasBothChildren: Bool { get }
}
