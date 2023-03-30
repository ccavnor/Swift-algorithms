//
//  TreeProtocol.swift
//  
//
//  Created by Christopher Charles Cavnor on 1/10/23.
//
import Foundation

// Notes for Foundation prototypes:
// Comparable :: <, <=, >=, and >
// AdditiveArithmatic :: +, +=, -, -=, zero
// Number: AdditiveArithmatic :: *, *= // not required?
// Bound (The type for which the expression describes a range): associatedtype Bound : Comparable
// Range (A half-open interval from a lower bound up to, but not including, an upper bound): RangeExpression :: ..<, ==, !==, ~=, overlaps
// ClosedRange (includes both bounds): RangeExpression :: ..., ==, !==, ~=, overlaps
// RangeExpression (A type that can be used to slice a collection) :: ~=
//      array[..<3] // PartialRangeUpTo<Int>
//      array[...3] // PartialRangeThrough<Int>
//      array[1...3] // ClosedRange<Int>
//      array[1...] // PartialRangeFrom<Int>



// MARK: Errors
public enum TreeError: Error {
    case notBalanced
    case invalidTree
    case invalidInterval
}

// MARK: Binary Search Tree Protocol
public protocol TreeValueP: AdditiveArithmetic & Comparable {
    associatedtype NodeValue: TreeValueP
}

public protocol TreeNodeP: AnyObject, Comparable {
    associatedtype NodeType: TreeNodeP
    associatedtype NodeValue: TreeValueP

    init(value: NodeValue)
    init(node: NodeType)

    var value: NodeValue { get set }
    var length: Float { get }

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
// Comparable conformance for Tree Node types
extension TreeNodeP {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs < rhs
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.value == rhs.value
    }
}
// default implementations
extension TreeNodeP where NodeValue == NodeType.NodeValue {
    public var length: Float {
        return 0
    }

    public var isRoot: Bool {
        return parent == nil
    }

    public var isLeaf: Bool {
        return left == nil && right == nil
    }

    /// Returns true iff node is left of its parent
    public var isLeftChild: Bool {
        return parent?.left === self
    }

    /// Returns true iff node is right of its parent
    public var isRightChild: Bool {
        return parent?.right === self
    }

    public var hasLeftChild: Bool {
        return left != nil
    }

    public var hasRightChild: Bool {
        return right != nil
    }

    public var hasAnyChild: Bool {
        return hasLeftChild || hasRightChild
    }

    public var hasBothChildren: Bool {
        return hasLeftChild && hasRightChild
    }
}

public protocol TreeP: AnyObject {
    associatedtype NodeType: TreeNodeP
    associatedtype NodeValue: TreeValueP

    init(value: NodeValue)
    init(node: NodeType)
    init(array: [NodeValue])

    var root: NodeType? { get set }
    var nodeCount: Int { get set }

    // MARK: - Adding items
    // returns Self so cannot be implemented in protocol extension
    @discardableResult func insert(node: NodeType) throws -> NodeType

    // MARK: - Deleting items
    // returns Self so cannot be implemented in protocol extension
    @discardableResult func remove(value: NodeValue) -> NodeType?

    // MARK: - Searching
    func search(value: NodeValue) -> NodeType?
    func contains(value: NodeValue) -> Bool
    func minimum() -> NodeType?
    func maximum() -> NodeType?
    func predecessor(value: NodeValue) -> NodeValue?
    func successor(value: NodeValue) -> NodeValue?
    // NOTE: func subscript(key: NodeValue) -> NodeValue? should be here but its a keyword so cannot add without backticks

    // MARK: - Tree information
    func height() -> Int // distance from root to the lowest leaf
    func height(node: NodeType?) -> Int // distance from given node to the lowest leaf
    var size: Int { get }  // number of nodes in tree
    func inLeftTree(value: NodeValue) -> Bool
    func inRightTree(value: NodeValue) -> Bool

    // MARK: - Traversal
    func traverseInOrder(completion: (NodeValue) -> Void)
    func traversePreOrder(completion: (NodeValue) -> Void)
    func traversePostOrder(completion: (NodeValue) -> Void)
    func map(_ formula: (NodeValue) -> NodeValue) -> [NodeValue]

    // MARK: - output
    func toArray() -> [NodeValue]
    func draw()
}
// default implementations that are common to TreeP types
extension TreeP where NodeValue == NodeType.NodeValue, NodeType == NodeType.NodeType { // NodeType.NodeType occurs with node.right etc

    // convenience
    public init(array: [NodeValue]) {
        precondition(array.count > 0)
        self.init(value: array.first!)
        for v in array.dropFirst() {
            _ = try? insert(node: NodeType(value: v))
        }
    }

    // MARK: - Tree Structure

    /// How many nodes are in this tree. Performance: O(n).
    public var size: Int {
        return nodeCount
    }

    /// Calculates the height of the tree, i.e. the distance from root to the lowest leaf. A tree of one node has height == 1.
    /// Since this looks at all children of tree, performance is O(n).
    public func height() -> Int {
        guard let root = self.root else {
            return 0
        }
        return height(node: root)
    }

    public func height(node: NodeType?) -> Int {
        guard let node = node, let _ = self.root else {
            return 0
        }
        let lHeight = height(node: node.left)
        let rHeight = height(node: node.right)
        return max(lHeight, rHeight) + 1
    }

    /// Returns true iff node is in the left subtree of root
    public func inLeftTree(value: NodeValue) -> Bool {
        // in case root is not set
        guard let root = self.root else { return false }
        // root is in neither subtree
        if value < root.value { return true }
        return false
    }

    /// Returns true iff node is in the right subtree of root
    public func inRightTree(value: NodeValue) -> Bool {
        // in case root is not set
        guard let root = self.root else { return false }
        // root is in neither subtree
        if value > root.value { return true }
        return false
    }

    // MARK: - Searching
    /// Finds the "highest" (in tree) node with the specified value.
    /// Performance: runs in O(h) time, where h is the height of the tree.
    public func search(value: NodeValue) ->  NodeType? {
        guard let root = self.root else {
            return nil
        }
        var node: NodeType? = root
        if root.value == value {
            return root
        }
        while let n = node {
            if value < n.value {
                node = n.left
            } else if value > n.value {
                node = n.right
            } else {
                return n
            }
        }
        return node
    }

    // MARK: - Adding items
    /// Inserts a new element into the tree. You should randomly insert elements at the root, to make to sure this remains a valid
    /// binary tree! Duplicate values are ignored, but this incurs a lookup penalty.
    /// Performance: runs in O(h) time, where h is the height of the tree.
    @discardableResult public func insert(node: NodeType) throws -> NodeType {
        // in case root is not set
        guard let root = self.root else {
            throw TreeError.invalidTree
        }
        // TODO: reimplement contains as a hash for constant time lookup
        // used to prevent duplicate values being inserted into tree
        if self.contains(value: node.value) {
            return node
        }
        return insert(tree: root, node: node, parent: nil)
    }

    @discardableResult public func insert(tree: NodeType,
                                          node: NodeType,
                                          parent: NodeType?) -> NodeType {
        var insertionNode = node
        let parent = parent ?? root
        let nodeType = type(of: node)

        if node.value < tree.value {
            if let left = tree.left {
                insert(tree: left,
                       node: node,
                       parent: left)
            } else {
                let temp = nodeType.init(value: node.value)
                tree.left = temp
                temp.parent = parent
                insertionNode = temp
                nodeCount += 1
            }
        } else {
            if let right = tree.right {
                insert(tree: right,
                       node: node,
                       parent: right)
            } else {
                let temp = nodeType.init(value: node.value)
                tree.right = temp
                temp.parent = parent
                insertionNode = temp
                nodeCount += 1
            }
        }
        return insertionNode
    }

    // MARK: - Deleting items
    /// Deletes a node from the tree.
    /// Performance: runs in O(h) time, where h is the height of the tree.
    @discardableResult public func remove(value: NodeValue) -> NodeType? {
        guard let replace = search(value: value) else {
            return nil
        }

        if nodeCount == 1 {
            root = nil
            nodeCount = 0
        } else {
            do {
                try deleteNode(node: replace)
                nodeCount -= 1
            } catch {
                // not a fatal error - node might not exist
                print("!!! unable to remove node \(replace.value)")
                return nil
            }
        }
        return replace
    }

    public func deleteNode(node: NodeType) throws {
        if node.isLeaf {
            // Just remove and balance up
            if let parent = node.parent {
                guard node.isLeftChild || node.isRightChild else {
                    throw TreeError.invalidTree
                }

                if node.isLeftChild {
                    parent.left = nil
                } else if node.isRightChild {
                    parent.right = nil
                }
            } else {
                // at root
                root = nil
            }
        } else {
            // Handle stem cases
            if let left = node.left {
                // replace with max valued node from left tree
                if let replacement = maximum(node: left) {
                    // give the deleted node its replacement's value
                    node.value = replacement.value
                    // then delete the replacement
                    try? deleteNode(node: replacement)
                }
                // replace with min valued node from right tree
            } else if let right = node.right {
                if let replacement = minimum(node: right), replacement !== node {
                    // give the deleted node its replacement's value
                    node.value = replacement.value
                    // then delete the replacement
                    try? deleteNode(node: replacement)
                }
            }
        }
    }

    public func contains(value: NodeValue) -> Bool {
        return search(value: value) != nil
    }

    /// Returns the leftmost descendent of tree. O(h) time.
    public func minimum() -> NodeType? {
        var node = self.root
        while let next = node?.left {
            node = next
        }
        return node
    }

    /// Returns the leftmost descendent of given node. O(h) time.
    public func minimum(node: NodeType) -> NodeType? {
        var n = node
        // TODO: contains check only adds time complexity?
        if !self.contains(value: n.value) { return nil }
        while let next = n.left {
            n = next
        }
        return n
    }

    /// Returns the rightmost descendent of tree. O(h) time.
    public func maximum() -> NodeType? {
        var node = self.root
        while let next = node?.right {
            node = next
        }
        return node
    }

    /// Returns the rightmost descendent of given node. O(h) time.
    public func maximum(node: NodeType) -> NodeType? {
        var n = node
        // TODO: contains check only adds time complexity?
        if !self.contains(value: n.value) { return nil }
        while let next = n.right {
            n = next
        }
        return n
    }

    /// Finds the node whose value preceedes our value in sorted order.
    public func predecessor(value: NodeValue) -> NodeValue? {
        guard let root = self.root else { return nil }
        guard let node = search(value: value) else { return nil }
        var result = [NodeValue]()
        traverseInOrder(node: root, completion: { if $0 < node.value { result.append($0) }})
        return result.popLast()
    }

    /// Finds the node whose value succeeds our value in sorted order.
    public func successor(value: NodeValue) -> NodeValue? {
        guard let root = self.root else { return nil }
        guard let node = search(value: value) else { return nil }
        var result = [NodeValue]()
        traverseInOrder(node: root, completion: { if $0 > node.value { result.append($0) }})
        return result.first
    }

    // MARK: - Traversal

    /// In-order traversal using given function as accumulator for node values.
    /// use like this:
    /// ```
    /// var inOrder = [Int]()
    /// tree.traverseInOrder { inOrder.append($0) }
    /// ```
    public func traverseInOrder(completion: (NodeValue) -> Void) {
        guard let root = self.root else { return }
        traverseInOrder(node: root, completion: completion)
    }

    private func traverseInOrder(node: NodeType, completion: (NodeValue) -> Void) {
        if let left = node.left { traverseInOrder(node: left, completion: completion) }
        completion(node.value)
        if let right = node.right { traverseInOrder(node: right, completion: completion) }
    }

    /// Pre-order traversal using given function as accumulator for node values.
    /// use like this:
    /// ```
    /// var preOrder = [Int]()
    /// tree.traversePreOrder { preOrder.append($0) }
    /// ```
    public func traversePreOrder(completion: (NodeValue) -> Void) {
        guard let root = self.root else { return }
        traversePreOrder(node: root, completion: completion)
    }

    private func traversePreOrder(node: NodeType,
                                  completion: (NodeValue) -> Void) {
        completion(node.value)
        if let left = node.left { traversePreOrder(node: left, completion: completion) }
        if let right = node.right { traversePreOrder(node: right, completion: completion) }
    }

    /// Post-order traversal using given function as accumulator for node values.
    /// use like this:
    /// ```
    /// var postOrder = [Int]()
    /// tree.traversePostOrder { postOrder.append($0) }
    /// ```
    public func traversePostOrder(completion: (NodeValue) -> Void) {
        guard let root = self.root else { return }
        traversePostOrder(node: root, completion: completion)
    }

    private func traversePostOrder(node: NodeType, completion: (NodeValue) -> Void) {
        if let left = node.left { traversePostOrder(node: left, completion: completion) }
        if let right = node.right { traversePostOrder(node: right, completion: completion) }
        completion(node.value)
    }

    /// Performs an in-order traversal, applying the given map function, and collects the values in an array.
    public func map(_ formula: (NodeValue) -> NodeValue) -> [NodeValue] {
        var result = [NodeValue]()
        guard let root = self.root else {
            return result
        }
        map(node: root, apply: formula, result: &result)
        return result
    }

    private func map(node: NodeType,
                     apply: ((NodeValue) -> NodeValue),
                     result: inout [NodeValue]) {
        if let left = node.left { map(node: left, apply: apply, result: &result) }

        let newValue = apply(node.value)
        node.value = newValue // update tree
        result.append(newValue) // append to results (inorder)

        if let right = node.right { map(node: right, apply: apply, result: &result) }
    }

    public func toArray() -> [NodeValue] {
        var inOrder = [NodeValue]()
        traverseInOrder { inOrder.append($0) }
        return inOrder
    }
}

// MARK: Interval Tree Protocol
public protocol IntervalTreeValueP: TreeValueP {
    var start: NodeValue { get set }
    var end: NodeValue { get set }
}

public protocol IntervalTreeNodeP: TreeNodeP {}


// MARK: Interval Tree Implementation
public struct Interval<T: IntervalTreeValueP>: IntervalTreeValueP {
    public typealias NodeValue = T

    public var start: T
    public var end: T

    public init(start: T, end: T) throws {
        if end < start { throw TreeError.invalidInterval }
        self.start = start
        self.end = end
    }
}

// MARK: Extensions
extension Interval: Comparable {
    /// == (equality)
    /// check that two intervals begin and end at same values
    public static func == (lhs: Interval<T>, rhs: Interval<T>) -> Bool {
        return (lhs.start == rhs.start) && (lhs.end == rhs.end)
    }

    /// != (non-equality)
    /// check that two intervals do not overlap
    public static func != (lhs: Interval<T>, rhs: Interval<T>) -> Bool {
        return !(lhs == rhs)
    }

    /// > (gt)
    /// reference interval must be to the right of test interval end
    public static func > (lhs: Interval, rhs: Interval) -> Bool {
        (lhs.start > rhs.end)
    }

    /// >=  (gte)
    /// reference interval must begin at or to the right of test interval end
    public static func >= (lhs: Interval, rhs: Interval) -> Bool {
        if lhs == rhs { return true }
        return (lhs.start >= rhs.end)
    }

    /// < (lt)
    /// test interval must be to the right of reference interval end
    public static func < (lhs: Interval, rhs: Interval) -> Bool {
        return (rhs > lhs)
    }

    /// <= (lte)
    /// test interval must begin at or to the right of reference interval end
    public static func <= (lhs: Interval, rhs: Interval) -> Bool {
        if lhs == rhs { return true }
        return (rhs >= lhs)
    }
}

extension Interval: AdditiveArithmetic {
    public static var zero: Interval<T> {
        return try! self.init(start: 0 as! T, end: 0 as! T)
    }

    public static func - (lhs: Interval<T>, rhs: Interval<T>) -> Interval<T> {
        return try! Self.init(start: (lhs.start - rhs.start), end: (lhs.end - rhs.end))
    }

    public static func + (lhs: Interval<T>, rhs: Interval<T>) -> Interval<T> {
        return try! Self.init(start: (lhs.start + rhs.start), end: (lhs.end + rhs.end))
    }
}

extension Int: TreeValueP & IntervalTreeValueP {
    public typealias NodeValue = Int

    public var start: Int {
        get {
            return self
        }
        set {
            self = newValue
        }
    }

    public var end: Int {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}

extension UInt: TreeValueP & IntervalTreeValueP {
    public typealias NodeValue = UInt
    public var start: UInt {
        get {
            return self
        }
        set {
            self = newValue
        }
    }

    public var end: UInt {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}
extension Float: TreeValueP & IntervalTreeValueP {
    public typealias NodeValue = Float
    public var start: Float {
        get {
            return self
        }
        set {
            self = newValue
        }
    }

    public var end: Float {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}
extension Double: TreeValueP & IntervalTreeValueP {
    public typealias NodeValue = Double
    public var start: Double {
        get {
            return self
        }
        set {
            self = newValue
        }
    }

    public var end: Double {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}
